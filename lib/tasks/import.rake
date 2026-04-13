namespace :import do
  desc "Import posts from PHP flat-file message board"
  task posts: :environment do
    data_dir = File.join(Rails.root.parent, "php/mb/gnxmb")
    threads_file = File.join(data_dir, "threads")

    unless File.exist?(threads_file)
      puts "ERROR: threads file not found at #{threads_file}"
      exit 1
    end

    puts "Reading threads file..."
    thread_entries = {}
    File.readlines(threads_file).each do |line|
      line.strip!
      next if line.empty?
      parts = line.split("::")
      start_ts = parts[0].to_i
      last_ts = parts[1].to_i
      reply_count = parts[2].to_i
      thread_entries[start_ts] = { last_ts: last_ts, reply_count: reply_count }
    end
    puts "Found #{thread_entries.size} thread entries"

    # Create all threads first
    puts "Creating threads..."
    thread_map = {} # original_timestamp => DiscussionThread id
    thread_entries.each do |start_ts, info|
      thread = DiscussionThread.create!(
        original_timestamp: start_ts,
        last_post_at: Time.at(info[:last_ts]),
        created_at: Time.at(start_ts),
        updated_at: Time.at(start_ts)
      )
      thread_map[start_ts] = thread.id
    end
    puts "Created #{thread_map.size} threads"

    # Import all .dat files
    dat_files = Dir.glob(File.join(data_dir, "*.dat")).sort
    puts "Found #{dat_files.size} .dat files to import"

    imported = 0
    orphans = 0
    errors = 0

    dat_files.each_with_index do |dat_file, idx|
      begin
        filename_ts = File.basename(dat_file, ".dat").to_i
        content = File.read(dat_file, encoding: "ISO-8859-1").encode("UTF-8", invalid: :replace, undef: :replace)
        lines = content.split("\n")

        next if lines.size < 3

        # Line 1: THREAD_ID::PREV_SIBLING_ID
        line1_parts = lines[0].split("::")
        thread_ts = line1_parts[0].to_i

        # Line 2: NEXT_SIBLING_ID (skip, not needed for import)
        # Line 3: USERNAME::::SUBJECT::IP_ADDRESS
        line3 = lines[2]
        meta_parts = line3.split("::::")
        username = meta_parts[0] || ""

        # The rest after :::: is SUBJECT::IP_ADDRESS
        subject_and_ip = meta_parts[1] || ""
        # Split on last :: to get subject and IP
        last_sep = subject_and_ip.rindex("::")
        if last_sep
          subject = subject_and_ip[0...last_sep]
          ip_address = subject_and_ip[(last_sep + 2)..]
        else
          subject = subject_and_ip
          ip_address = ""
        end

        # Lines 4+: body
        body = (lines[3..] || []).join("\n")

        # Rewrite smiley paths
        body.gsub!(%r{<img src="\.\./smileys/}, '<img src="/smileys/')

        # Find the thread
        db_thread_id = thread_map[thread_ts]
        unless db_thread_id
          orphans += 1
          next
        end

        Post.create!(
          thread_id: db_thread_id,
          original_timestamp: filename_ts,
          username: username.strip,
          subject: subject.strip,
          body: body,
          ip_address: ip_address.strip,
          created_at: Time.at(filename_ts),
          updated_at: Time.at(filename_ts)
        )

        imported += 1
        print "\rImported #{imported}/#{dat_files.size} posts..." if imported % 100 == 0
      rescue => e
        errors += 1
        puts "\nError importing #{dat_file}: #{e.message}"
      end
    end

    puts "\n\nImport complete!"
    puts "  Threads: #{thread_map.size}"
    puts "  Posts imported: #{imported}"
    puts "  Orphan posts (no matching thread): #{orphans}"
    puts "  Errors: #{errors}"

    # Update last_post_at for all threads based on actual post data
    puts "Updating thread last_post_at..."
    DiscussionThread.find_each do |thread|
      latest = thread.posts.maximum(:created_at)
      thread.update_column(:last_post_at, latest) if latest
    end
    puts "Done!"
  end
end
