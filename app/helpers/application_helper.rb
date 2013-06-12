module ApplicationHelper
  def homework_dest_for(number, id=nil)
    if id == nil
      "/tmp2/oop#{number}"
    end

    "/tmp2/oop#{number}/#{id}"
  end

  def origin_for(repo)
    `cd #{repo.working_dir} && git config --get remote.origin.url`.strip
  end
end
