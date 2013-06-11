require 'grit'

class SubmitController < ApplicationController
  def git
    @hw_id = params[:hw_id]
    @student_id = params[:student_id]
    @repo = params[:url].strip

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
      render :json => { :message => 'Failed to create directory.', :error => e.message }, :status => 500
      return
    end
    version += 1
    
    # clone repo
    git = Grit::Git.new(dest)
    repo_dir = File.join(dest, version.to_s)
    info = git.clone({ :timeout => 60, :process_info => true }, @repo, repo_dir)
    if info[0] != 0
      render :json => { :message => 'Git clone failed.', :error => info[2] }, :status => 400 
      return
    end

    # return repo info
    begin
      repo = Grit::Repo.new(repo_dir)
    rescue Grit::NoSuchPathError => e
      render :json => { :message => 'Git clone failed.', :error => e.message }, :status => 400
      return
    end
    head = repo.commits.first
    render :json => { :message => 'Git clone succeeded.', :version => version, :repo => @repo, :info => head }
  end
end
