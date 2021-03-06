import { Controller } from 'stimulus';
import { fetchStatus, fetchJson, sendNotification } from '../../lib/utils';
import { Sortable } from '@shopify/draggable';
import $ from 'jquery';
import moment from 'moment-timezone';

/**
 * Controls the sorting of the queue.
 * @extends Controller
 */
export default class extends Controller {
  static targets = ['container', 'card', 'buttons'];

  connect () {
    // Grab the CSRF token from the document head so we can send it in Fetch requests
    this.csrfToken = document.querySelector('[name=csrf-token]').getAttribute('content');
    this.entriesPublishedToday = parseInt(this.data.get('entries-published-today'), 10);
    this.entriesPublishedPerDay = parseInt(this.data.get('entries-published-per-day'), 10);
    this.timeZone = this.data.get('time-zone');
    this.sortableQueue = new Sortable(this.containerTarget, {
      draggable: '.draggable-handle',
      delay: 100,
      classes: {
        'source:dragging': 'draggable-dragging'
      }
    });
    this.sortableQueue.on('drag:start', event => this.startSort(event));
    this.sortableQueue.on('mirror:destroy', () => this.updateCards());
    this.updateCards();
  }

  /**
   * Hides the discard and save buttons
   */
  hideButtons () {
    this.buttonsTarget.classList.add('is-hidden');
  }

  /**
   * Shows the discard and save buttons
   */
  showButtons () {
    this.buttonsTarget.classList.remove('is-hidden');
  }

  /**
   * Disables the ability to drag an element.
   */
  disableDrag () {
    this.cardTargets.forEach(card => card.classList.remove('draggable-handle'));
  }

  /**
   * Enables the ability to drag an element.
   */
  enableDrag () {
    this.cardTargets.forEach(card => card.classList.add('draggable-handle'));
  }

  /**
   * Handles the start of a sorting event, hardcoding the size of the dragged
   * element so it doesn't look weird while being dragged.
   * Sortable events docs: https://github.com/Shopify/draggable/tree/master/src/Sortable/SortableEvent
   * @param {Event} event A sortable:start event.
   */
  startSort (event) {
    let mirror = event.data.mirror;
    let originalWidth = event.data.source.clientWidth;
    mirror.style.width = `${originalWidth}px`;
  }

  /**
   * Updates the timestamps and attributes for each card, based on their order in the queue.
   */
  updateCards () {
    this.hideButtons();
    this.cardTargets.filter(card => !card.classList.contains('draggable-mirror')).forEach((card, i) => {
      const originalPosition = parseInt(card.getAttribute('data-entry-position-original'), 10);
      const position = i + 1;
      let publish_date;
      if (this.entriesPublishedPerDay === 0) {
        publish_date = 'N/A';
      } else {
        const days = Math.floor((position - 1 + this.entriesPublishedToday)/this.entriesPublishedPerDay);
        publish_date = moment().tz(this.timeZone).add(days, 'days').format('dddd, MMMM D, YYYY');
      }
      card.setAttribute('data-entry-position', position);
      card.querySelector('[data-timestamp]').innerHTML = publish_date;
      if (position !== originalPosition) {
        this.showButtons();
      }
    });
  }

  /**
   * Updates the stored positions of the cards after saving.
   */
  updateCardPositions () {
    this.cardTargets.forEach((card, i) => {
      const position = i + 1;
      card.setAttribute('data-entry-position-original', position);
    });
  }

  /**
   * Puts the queue back in the original order.
   * @param {Event} event A click event from the cancel button.
   */
  discard (event) {
    event.preventDefault();
    const container = $(this.containerTarget);
    if (!window.confirm('Are you sure you want to discard the changes you’ve made?')) {
      return false;
    }

    this.cardTargets
      .sort((a, b) => {
        const a_position = parseInt(a.getAttribute('data-entry-position-original'), 10);
        const b_position = parseInt(b.getAttribute('data-entry-position-original'), 10);
        return a_position - b_position;
      }).forEach(card => {
        container.append($(card).detach());
      });

    this.updateCards();
    sendNotification('The changes you’ve made to the queue have been discarded.', 'danger');
  }

  /**
   * Saves the new queue order.
   * @param {Event} event A click event from the save button.
   */
  save (event) {
    event.preventDefault();
    if (!window.confirm('Are you sure you want to save the changes you’ve made?')) {
      return false;
    }

    this.hideButtons();
    this.disableDrag();
    const entry_ids = this.cardTargets.map(card => parseInt(card.getAttribute('data-entry-id'), 10));
    const url = this.data.get('endpoint');
    const fetchOpts = {
      method: 'POST',
      body: JSON.stringify({ entry_ids: entry_ids }),
      headers: new Headers({
        'Content-Type': 'application/json',
        'X-CSRF-Token': this.csrfToken
      }),
      credentials: 'include'
    };

    const firstWarning = setTimeout(() => sendNotification('Your changes are being saved, this will take a few seconds.', 'warning'), 1000);
    const secondWarning = setTimeout(() => sendNotification('Hang tight, your changes are still being saved.', 'warning'), 5000);
    fetch(`${url}.json`, fetchOpts)
      .then(fetchStatus)
      .then(fetchJson)
      .then(json => {
        clearTimeout(firstWarning);
        clearTimeout(secondWarning);
        sendNotification(json.message, json.status);
        this.updateCardPositions();
        this.enableDrag();
      });
  }
}
