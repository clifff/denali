import { Controller } from 'stimulus';
import { fetchStatus, sendNotification } from '../../lib/utils';
import { Sortable } from '@shopify/draggable';
import $ from 'jquery';
import moment from 'moment';

/**
 * Controls the sorting of the queue.
 * @extends Controller
 */
export default class extends Controller {
  static targets = ['container', 'card', 'button'];

  connect () {
    // Grab the CSRF token from the document head so we can send it in Fetch requests
    this.csrfToken = document.querySelector('[name=csrf-token]').getAttribute('content');
    this.queueHasPublishedToday = this.data.get('has-published-today') === 'true';
    this.sortableQueue = new Sortable(this.containerTarget, {
      draggable: '.card',
      delay: 100,
      classes: {
        'source:dragging': 'is-invisible'
      }
    });
    this.sortableQueue.on('mirror:destroy', () => this.updateCards());
    this.updateCards();
  }

  /**
   * Hides the discard and save buttons
   */
  hideButtons () {
    this.buttonTargets.forEach(button => button.classList.add('is-hidden'));
  }

  /**
   * Shows the discard and save buttons
   */
  showButtons () {
    this.buttonTargets.forEach(button => button.classList.remove('is-hidden'));
  }

  /**
   * Updates the timestamps and attributes for each card, based on their order in the queue.
   */
  updateCards () {
    this.hideButtons();
    this.cardTargets.filter(card => !card.classList.contains('draggable-mirror')).forEach((card, i) => {
      const originalPosition = parseInt(card.getAttribute('data-entry-position-original'), 10);
      const position = i + 1;
      const days = this.queueHasPublishedToday ? position : position - 1;
      card.setAttribute('data-entry-position', position);
      card.querySelector('[data-timestamp]').innerHTML = moment().add(days, 'days').format('dddd, MMMM D, YYYY');
      if (position !== originalPosition) {
        this.showButtons();
      }
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

    const firstWarning = setTimeout(() => sendNotification('The changes you’ve made to the queue are being saved!'), 1000);
    const secondWarning = setTimeout(() => sendNotification('Hang tight, saving your queue is taking longer than expected.', 'warning'), 5000);
    fetch(`${url}.json`, fetchOpts)
      .then(fetchStatus)
      .then(() => {
        clearTimeout(firstWarning);
        clearTimeout(secondWarning);
        sendNotification('The changes you’ve made to the queue have been saved!');
      });
  }
}