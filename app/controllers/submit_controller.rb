require 'grit'

class SubmitController < ApplicationController

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
    @job.delay.delayed_clone(@job.id, @hw_id, @student_id, @url)
    render :json =>{'status'=>0, 'id'=>@job.id}
  end

end
