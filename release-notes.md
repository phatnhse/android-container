### Release-v1.0

```console
docker pull codecaigicungduoc/android-container:1.0
```

**Change Log**
* Build Project with Gradle Wrapper and persist its dependencies and files at `~/cache` 
* Support both ARM and x86 emulators 

| Component                   | Version      | Description                         |
|-----------------------------|--------------|-------------------------------------|
| Ubuntu                      | 18:04        | Base image                          |
| Build Tools                 | 30.0.0_rc1   | Android SDK Build-Tools (Feb 2020)  |
| Java                        | 1.8.0_242    | Java8                               |

### Release-v1.1
```console
docker pull codecaigicungduoc/android-container:1.1
```
**Change Log**
* Update Build Tools to `30.0.0` (May 2020 - Android 11)
* Deprecate ARM Emulator since nested virtualization is yet support on macOS & VirtualBox. It is extremely slow to boot.  

| Component                   | Version      | Description                         |
|-----------------------------|--------------|-------------------------------------|
| Ubuntu                      | 18:04        | Base image                          |
| Build Tools                 | 30.0.0       | Android SDK Build-Tools (May 2020)  |
| Java                        | 1.8.0_242    | Java8                               |