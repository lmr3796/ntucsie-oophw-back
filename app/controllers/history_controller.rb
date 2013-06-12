class HistoryController < ApplicationController

  def individual
    #@email = params[:email]
    @hw_id = params[:hw_id]
    @student_id = params[:student_id]
    @submissions = []

    dest = homework_dest_for(@hw_id, @student_id)
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

  def full_hw
    @students = []
    @hw_id = params[:hw_id]
    @hw_deadline  = Time.new(2013, 4, 11, 12, 00)

    root = homework_dest_for(@hw_id)
    Dir.foreach(root) do |id|
      if id.start_with? '.'
        next
      end

      submissions = []

      dest = File.join(root, id)
      Dir.foreach(dest) do |f|
        n = f.to_i
        if n.to_s != f
          next
        end

        repo_dir = File.join(dest, f)
        repo = Grit::Repo.new(repo_dir) rescue NoSuchPathError
        submissions.push({
          :version  => n,
          :repo     => origin_for(repo),
          :info     => repo.commits.first,
          :time     => File::Stat.new(repo_dir).ctime
        })
      end

      if submissions.length == 0
        next
      end

      @students.push({
        :id           => id,
        :submissions  => submissions.sort{|x,y| y[:version] <=> x[:version]}.group_by {|x|x[:repo]}.values.map{|x|x.first}
      })

      @students.sort! { |x,y| x[:id] <=> y[:id] }
    end
    render :json => {:status => 0, :hw_id => @hw_id, :deadline => @hw_id, :students => @students}
  end

end
