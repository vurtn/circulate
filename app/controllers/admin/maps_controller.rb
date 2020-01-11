module Admin
  class MapsController < BaseController
    def show
      data = Member.verified.group(:postal_code).count
      render xml: ChicagoMap.new(data)
    end
  end
end
