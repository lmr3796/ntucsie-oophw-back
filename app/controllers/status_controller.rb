class StatusController < ApplicationController
  def clone
    result = Clone.find(params[:job_id])
    if result.student != params[:student_id]
      render :json => {:message => 'User ID invalid!'}, :status => 400
    else
      send_back = {
          :message => result.message,
          :error => result.error,
          :version => result.version,
          :repo => result.url,
          :info => (result.info != "null" && result.info != nil)? JSON.parse(result.info) : nil,
      }
      render :json => send_back, :status => result.status
    end
  end

  def build
  end
end
