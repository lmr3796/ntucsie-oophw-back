require 'grit'

class SubmitController < ApplicationController
  def job_done(fields)
    @job.hw = fields[:hw]
    @job.url = fields[:url]
    @job.info = fields[:info]
    @job.message = fields[:message]
    @job.error = fields[:error]
    @job.version = fields[:version]
    @job.status = fields[:status]
    @job.save
  end
  def git
    @hw_id = params[:hw_id]
    @student_id = params[:student_id]
    @url = params[:url].strip

    # status 403 to indicate not done
    @job = Clone.new
    @job.hw = @hw_id
    @job.student = @student_id
    @job.url = @url
    @job.status = 403
    @job.save
    # create directory & get the newest version
    dest = homework_dest_for(@hw_id, @student_id)
    begin
      version = 0
      if File.directory?(dest)
        Dir.foreach(dest) do |f|
          n = f.to_i
          if n.to_s == f
            version = n if n > version
          end
        end
      else
        Dir.mkdir(dest, 0755)
      end
    rescue SystemCallError => e
      job_done(:message => 'Failed to create directory.', :error => e.message, :status => 500)
      return
    end
    version += 1
    render :json =>{'status'=>0, 'id'=>@job.id}
    
    # clone repo
    git = Grit::Git.new(dest)
    repo_dir = File.join(dest, version.to_s)
    info = git.clone({ :timeout => 60, :process_info => true }, @url, repo_dir)
    if info[0] != 0
      job_done(:message => 'Git clone failed.', :error => info[2] , :status => 400)
      return
    end

    # return repo info
    begin
      repo = Grit::Repo.new(repo_dir)
    rescue Grit::NoSuchPathError => e
      job_done(:message => 'Git clone failed.', :error => e.message , :status => 400)
      return
    end
    head = repo.commits.first
    job_done(:message => 'Git clone succeeded.', :version => version, :repo => @url, :info => head.to_json, :status => 200) 
  end
end
