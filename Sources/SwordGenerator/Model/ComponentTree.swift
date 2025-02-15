struct ComponentTree {
  let rootComponent: Component
  let subcomponentsByParent: [ComponentName: [Component]]
}
