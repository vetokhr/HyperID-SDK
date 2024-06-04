## Authorization in Hyper ID with React Native application using macOS and XCode iOS application

HyperID extends OpenID Connect protocol and you can easily authorize your user in the same way like other identity providers using any third party library what you like.
> Note: In this sample we're using `react-native-app-auth` package but you are free to choose more simple or complicated solutions for this

## Sample

All next acctions you could execute in Terminal what you like

### 1. Clone this repo
```Bash
    git clone <link>
```
### 2. Make sure that you have installed:
`nodeJS`, `npm`, `yarn` and `cocoapods`.

> If you don't, use `homebrew` to do this:
>  
> #### 2.1. Insall `homebrew`
> ```Bash
>    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
> ```
>
> #### 2.2. Instal `NodeJS` with `npm`
>
> ```Bash
>    brew install node
> ```
>
> #### 2.3. Install `yarn`
>
> ```Bash
>    npm install --global yarn
> ```
>
> #### 2.4. Install `cocoapods`
>
> ```Bash
>    sudo gem install cocoapods
> ```

### 3. Open cloned repo

```Bash
    cd /path/to/the/react-native-app-auth
```

### 4. Open example folder

```Bash
    cd ./Example
```

### 5. Resolve Example dependencies with `yarn`

```Bash
    yarn install
```

### 6. Open `ios` folder and resolve `XCode` dependencies with `cocoapods`

```Bash
    pod install
```

### 7. Configure application for your client

* Open `Example/App.js` and edit your `auth` config (row 20). You should replace `clientId`, `clientSecret`, `redirectUrl` placeholders with your data recieved after client registration.
* Search and replace in project redirect url scheme `your.custom.scheme` to yours for correct authorization completion processing usualy it's `build.gradle` and `Info.plist` files.

### 7. Let's open `XCode` solution in `Example/ios` folder

```Bash
    open Example.xcworkspace
```

### 8. Try to build solution

For this you can use `Command+B` shortcut or use app menu `Product -> Build`

> Note: You could have some issues with third party Facebook's `FlipperKit`. You can easily fix that by editing `FlipperTransportTypes.h` header file and add include of C++ STL header right after `#include <string>` at row 10:
>> ```C++
>> #include <functional>
>> ```

### 9. Run

1. Make sure your scheme has `Release` build configuration and run the project using `XCode`. Use `Run` button or use app menu `Product -> Run`.
