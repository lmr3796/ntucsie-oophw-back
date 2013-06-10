class HistoryController < ApplicationController
  def get
    #@email = params[:email]
    @hw_id = params[:hw_id]
    @student_id = params[:student_id]
    @submissions = []

    dest = homework_dest_for(params[:hw_id], @student_id)
    FileUtils.mkdir_p dest unless File.directory?(dest)
    Dir.foreach(dest) do |f|
      n = f.to_i
      if n.to_s != f
        next
      end

      repo_dir = File.join(dest, f)
      @repo = Grit::Repo.new(repo_dir) rescue nil
      @submissions.push({
        :hw       => @hw_id,
        :version  => n,
        :repo     => origin_for(@repo),
        :info     => @repo.commits.first,
        :time     => File::Stat.new(repo_dir).ctime
      }) 
    end
    @submissions.sort! { |x,y| y[:version] <=> x[:version] }

    render :json => { :status => 'success', :submissions => @submissions }
    return
  end
end
