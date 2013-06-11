require 'open3'
class BuildController < ApplicationController
  def build 
    command = 'make'
    student_id = params[:student_id]
    hw_id = params[:hw_id]
    version = params[:version]
    dest = "#{homework_dest_for(hw_id, student_id)}/#{version}"
    stdout, stderr, status = Open3.capture3("cd #{dest} && #{command}")
    build_status = {}
    if status.exitstatus == 0
      build_status[:status] = 0
    else
      build_status[:status] = 1
      build_status[:message] = stderr.strip
    end
    render :json => build_status, :status => build_status[:status] == 0 ? 200 : 400
  end
end
