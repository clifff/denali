import { Controller } from 'stimulus';
import { fetchStatus, fetchText } from '../../lib/utils';
import $ from 'jquery';
import { Sortable } from '@shopify/draggable';
import Awesomplete from 'awesomplete';

/**
 * Controls the entry form.
 * @extends Controller
 */
export default class extends Controller {
  static targets = ['photos', 'tags', 'datalist'];

  /**
   * Sets up the tag autocomplete, and the drag-and-drop of photos.
   */
  connect () {
    new Awesomplete(this.tagsTarget, {
      list: this.datalistTarget,
      filter: function (text, input) {
        return Awesomplete.FILTER_CONTAINS(text, input.match(/[^,]*$/)[0]);
      },
      replace: function (text) {
        var before = this.input.value.match(/^.+,\s*|/)[0];
        this.input.value = `${before}${text}, `;
      }
    });

    new Sortable(this.photosTarget, {
      delay: 100,
      classes: {
        'source:dragging': 'form__photo--dragging',
        'mirror': 'form__photo--mirror'
      },
      handle: '.draggable-handle'
    });
  }

  /**
   * Fetches a new set of fields to add another photo to the entry,
   * add appends it to the form.
   * TODO: Remove jQuery dependency.
   * @param {Event} event A click event from the add photo button.
   */
  addPhoto (event) {
    event.preventDefault();
    const url = this.data.get('photo-endpoint');

    const fetchOpts = {
      method: 'GET',
      headers: new Headers({
        'X-CSRF-Token': this.csrfToken
      }),
      credentials: 'include'
    };

    fetch(`${url}`, fetchOpts)
      .then(fetchStatus)
      .then(fetchText)
      .then(html => $(this.photosTarget).append(html));
  }

  /**
   * Updates all the position fields on the photos before submitting the form,
   * setting them to their order in the DOM (which may change due to drag and drop).
   * @param {Event} event A submit event from the form.
   */
  submit (event) {
    event.preventDefault();
    this.element.querySelectorAll('[data-position]').forEach((element, index) => {
      element.value = index + 1;
    });
    event.target.submit();
  }
}
