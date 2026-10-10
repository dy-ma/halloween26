import type { AnimationCommand } from './animation-command'

export type AnimationCommandListener = (command: AnimationCommand) => void

export interface AnimationCommandSource {
  start(commandBus: AnimationCommandBus): () => void
}

export class AnimationCommandBus {
  readonly #listeners = new Set<AnimationCommandListener>()

  publish(command: AnimationCommand): void {
    for (const listener of this.#listeners) {
      listener(command)
    }
  }

  subscribe(listener: AnimationCommandListener): () => void {
    this.#listeners.add(listener)
    return () => this.#listeners.delete(listener)
  }
}
