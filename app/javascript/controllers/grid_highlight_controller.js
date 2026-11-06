import { Controller } from "@hotwired/stimulus";

// Marks the cards related to the selected one with data-highlight: "selected", "requires" (its prerequisites) or
// "unlocks" (subjects that need it).
// Colors and labels live in the card's CSS classes (tokens), never here.
export default class extends Controller {
  static targets = ["card"];
  static RELATIONS = Object.freeze({
    SELECTED: "selected",
    REQUIRES: "requires",
    UNLOCKS: "unlocks",
  });
  static ARIA_CURRENT_ATTR = "aria-current";
  static ID_SEPARATOR = " ";
  #pinnedCard = null;

  connect() {
    this.#pinnedCard = null;
  }

  toggle({ currentTarget }) {
    this.#updatePinnedCard(currentTarget);
    this.#render();
  }

  #updatePinnedCard(card) {
    this.#pinnedCard = this.#isPinned(card) ? null : card;
  }

  #isPinned(card) {
    return this.#pinnedCard === card;
  }

  #render() {
    this.cardTargets.forEach((card) => this.#updateCardView(card));
  }

  #updateCardView(card) {
    const relation = this.#relationToPinned(card);
    this.#updateHighlight(card, relation);
    this.#updateAriaCurrent(card, this.#isPinned(card));
  }

  #relationToPinned(card) {
    if (!this.#pinnedCard) {
      return null;
    }
    if (this.#isPinned(card)) {
      return this.constructor.RELATIONS.SELECTED;
    }
    if (this.#dependsOn(this.#pinnedCard, card)) {
      return this.constructor.RELATIONS.REQUIRES;
    }
    if (this.#dependsOn(card, this.#pinnedCard)) {
      return this.constructor.RELATIONS.UNLOCKS;
    }
    return null;
  }

  #dependsOn(subjectCard, prerequisiteCard) {
    const prerequisiteId = this.#subjectId(prerequisiteCard);
    return this.#requiredIds(subjectCard).includes(prerequisiteId);
  }

  #updateHighlight(card, relation) {
    if (relation) {
      card.dataset.highlight = relation;
    } else {
      delete card.dataset.highlight;
    }
  }

  #updateAriaCurrent(card, isSelected) {
    const attr = this.constructor.ARIA_CURRENT_ATTR;
    if (isSelected) {
      card.setAttribute(attr, "true");
    } else {
      card.removeAttribute(attr);
    }
  }

  #subjectId(card) {
    return card.dataset.subjectId;
  }

  #requiredIds(card) {
    const rawIds = card.dataset.requiredIds ?? "";
    return rawIds.split(this.constructor.ID_SEPARATOR).filter(Boolean);
  }
}
