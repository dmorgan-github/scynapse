# scynapse

## Modular system for SuperCollider
Built around JITLib Library and ProxySpace, scynapse provides an extensible module and component system to enable easy drag and drop routing of signals. Modules and components are entirely script based and can be hot-loaded without having to recompile. Also since scynapse is built around JITLib and ProxySpace you are not limited to the modules existing in scynapse. NodeProxies created at any time in the current environment can be used within scynapse and vice-versa.

!(scynapse.png)

### Requires
    SC3-plugins
    wslib
    ChannelEQ
    TabbedView
    JITLib Extensions
