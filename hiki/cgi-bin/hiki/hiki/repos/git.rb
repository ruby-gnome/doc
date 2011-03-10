require 'hiki/repos/default'
require 'English'

module Hiki
  class ReposGit < ReposBase
    def commit(page, msg = default_msg)
      Dir.chdir("#{@data_path}/text") do
        unless git("add", "--refresh", "--", page.escape)
          git("add", "--", page.escape)
        end
        git("commit", "-q", "-m", "\"#{msg}\"", "--", page.escape)
      end
    end

    def delete(page, msg = default_msg)
      Dir.chdir("#{@data_path}/text") do
        git("rm", "-q", "--", page.escape)
        git("commit", "-q", "-m", "\"#{msg}\"", "--", page.escape)
      end
    end

    def get_revision(page, revision)
      ret = ''
      revision = revision.gsub(/[^a-zA-Z\d]/, '')
      Dir.chdir("#{@data_path}/text") do
        open("|git cat-file blob #{revision}".untaint) do |f|
          ret = f.read
        end
      end
      ret
    end

    def revisions(page)
      require 'time'
      all_log = ''
      revs = []
      Dir.chdir("#{@data_path}/text") do
        open("|git log --raw -- #{page.escape.untaint}") do |f|
          all_log = f.read
        end
      end
      all_log.split(/^commit (?:[a-fA-F\d]+)\n/).each do |log|
        if /\AAuthor:\s*(.*?)\nDate:\s*(.*?)\n(.*?)
            \n:\d+\s\d+\s[a-fA-F\d]+\.{3}\s([a-fA-F\d]+)\.{3}\s\w
               \s+[^\n]*#{Regexp.escape(page.escape)}\n+\z/xm =~ log
          revs << [$4,
                   Time.parse("#{$2}Z").localtime.strftime('%Y/%m/%d %H:%M:%S'),
                   "", # $1,
                   $3.strip]
        end
      end
      revs
    end

    private
    def git(*args)
      command = args.join(" ").untaint
      `git #{command} > /dev/null`
      $?.success?
    end
  end
end
