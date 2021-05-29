import { Controller } from "stimulus"
import Sortable from "sortablejs"
import Rails from "@rails/ujs";

export default class extends Controller {
  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      onEnd: this.end.bind(this),
      onMove: this.move.bind(this),
      chosenClass: "sorting",
      ghostClass: "ghost",
    })
  }

  move(event) {
    this.moved = event.related;
  }

  end(event) {
    let id = event.item.dataset.id
    let data = new FormData()
    data.append("position", this.moved.dataset.position)

    Rails.ajax({
      url: this.data.get("url").replace(":id", id),
      type: 'PUT',
      data: data,
    })
  }
}