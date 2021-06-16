import { Controller } from "stimulus"
import Sortable from "sortablejs"
import Rails from "@rails/ujs";

export default class extends Controller {
  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      handle: ".drag-handle",
      filter: ".notified",
      onEnd: this.end.bind(this),
      onMove: (event) => {
        if (event.related.classList.contains('notified')) return false;
    },
      chosenClass: "sorting",
      ghostClass: "ghost",
    })
  }

  end(event) {
    console.debug(event);
    const id = event.item.dataset.id
    const index = event.newIndex;
    const previousItem = this.element.querySelector(`*[data-initial-index="${index}"]`);
    const position = previousItem.dataset.position;

    let data = new FormData()
    data.append("position", position)
    Rails.ajax({
      url: this.data.get("url").replace(":id", id),
      type: 'PUT',
      data: data,
    })
  }
}