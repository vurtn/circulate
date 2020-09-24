class AppointmentsController < ApplicationController
  def new
    @holds = Hold.active.where(member: current_user.member)
    @loans = Loan.where(member: current_user.member)
  end

  def create
  end
end
