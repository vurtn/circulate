module AdminHelper

  def index_header(title, &block)
    render "shared/index_header", title: title, &block
  end

  def flash_message(key)
    if flash.key?(key)
      tag.div(class: "toast toast-#{key}", data: {controller: "alert"}) do
        tag.button(class:"btn btn-clear float-right", data: {action: "alert#remove"}) + flash[key]
      end
    end
  end

  class DropdownMenu < BasicObject
    def initialize(template)
      @template = template
    end

    def method_missing(*args, &block)
      @template.send *args, &block
    end

    def render(&block)
      tag.div class: "dropdown dropdown-right" do
        concat(link_to("#", data: { turbolinks: false }, class: "btn btn-link dropdown-toggle", tabindex:"0") do
          tag.i class: "icon icon-more-horiz"
        end)
        concat(tag.ul(class: "menu") do
           block.call(self)
        end)
      end
    end
  end

  def dropdown_menu(&block)
    DropdownMenu.new(self).render do |menu|
      yield menu
    end
  end

end