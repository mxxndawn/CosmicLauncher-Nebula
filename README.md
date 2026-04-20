# Nebula

HeliosLaunehr(혹은 포크된 다른 런처)에 사용되는 distribution.json을 제작하는 도구 입니다.
Documentation on this format can be found [here][distro.md].

## Requirements

* Node.js 22
* Java 8+ (https://adoptium.net/)
  * This is required to run the forge installer, process [XZ](https://tukaani.org/xz/format.html) files, and run bytecode analysis on mod files.
  * Although 1.17 requires Java 16, the forge installer works with Java 8.

## Setup

1. repository를 Clone 한다.
2. 종속성을 설치한다. (`npm i`)
3. [`.env`][dotenvnpm]파일을 Clone된 폴더 최상단에 생성하고 아래와 같은 형식으로 내용을 입력한다.

.env 파일 예제
```properties
JAVA_EXECUTABLE=C:\Program Files\Eclipse Adoptium\jdk-17.0.12.7-hotspot\bin\java.exe
ROOT=D:\TestRoot2
BASE_URL=http://localhost:8080/
HELIOS_DATA_FOLDER=C:\Users\user\AppData\Roaming\Helios Launcher
```
## Setup & Using guide for KR

1. Repo 클론 : git clone <repo url>
2. 종속성 설치 : npm i
3. 작업데이터 환경변수 설정 : .env
   1. 'JAVA_EXECUTABLE=' : Nebula 작업중 Java가 필요한 단계에서 사용할 로컬 Java파일 경로. 필수.
   2. 'ROOT=' : 기본 작업폴더를 설정. 외부에 유지할지 내부에 유지할지는 자유이며, 비워둔다면 './' 경로를 사용하게됨. 추천은 './serverdata' (\가 아닌 / 임을 명시하자)
   3. 'BASE_URL=' : CDN Server의 DNS를 입력한다. 실제로 아래에서 파일위치<->원격위치의 치환이 진행된다. 반드시 http 또는 https를 포함해야한다.
   ${ROOT}/server/<서버명>/<forge/fabric>mods/<Mod Use Option/**<Mod Name>.jar
   ${BASE_URL}/servers/TEST123-1.20.1/fabricmods/<Mod Use Option>/<Mode Name>.jar
   4. 'HELIOS_DATA_FOLDER=' : --installLocal 옵션 사용시 필요한 경로. 일반적으로는 필요하지 않다.
4. 기본 작업폴더 생성 : npm run start -- init root
5. 서버 작업폴더 생성 : 기본 명령어 구성 npm run start -- generate server <서버명> <mc버전> <옵션> <옵션string>
   1. 기본 서버 생성시 : 서버명, mc버전은 필수로 작성
   npm run start --generate server TEST1 1.20.1
   2. forge 서버 생성시 : 옵션 string은 작성하지 않으면 옵션 비활성, latest/recommended 옵션 사용가능
   npm run start --generate server TEST-FORGE 1.20.1 --forge 47.4.20
   3. fabric 서버 생성시 : 옵션 string은 작성하지 않으면 옵션 비활성, latest/recommended 옵션 사용가능
   npm run start --generate server TEST-FABRIC 1.20.1 --fabric 0.19.2
6. ${ROOT}\servers\<서버명> 아래에 모드, 라이브러리, 설정파일 등 을 배치한다.
7. distribution.json 생성 : npm start -- generate distro
   
## Usage

Nebula는 개발중인 프로젝트 입니다. 사용방법은 변경될 수 있지만, 한동안 안정적으로 유지될 것 입니다.

#### TL;DR (Too Long; Didn't Read) Usage

This is the barebones overall usage. Please read the rest of this document.

* Follow the setup instructions above.
* Run the `init root` command.
* Generate servers using the `g server` command.
* Put all files in their respective folders (documented below).
* Generate the distribution using the `g distro` command.
* When in doubt, reread this document and then ask on Discord.

## Commands

Commands will be documented here. You can run any command with the `--help` option to view more information.

### Command Usage

This explains how to run the commands listed below. There are a few ways to run commands, pick your preferred method.

Example: To run `init root`, you would do `npm run start -- init root`.

*Recommended*

* Run **`npm run start -- <COMMAND>`**
  * *Why is this recommended? This command will compile the source code first.*

*Other*

* Build the project using **`npm run build`**
* Run **`node dist/index.js <COMMAND>`** OR **`npm run faststart -- <COMMAND>`**
  * `faststart` is an alias to run the main file without building.

> ***Note:***
> - ***If you modify any files, you will have to rebuild the project.***
> - ***After pulling from git, you will have to rebuild the project.***
>
> ***npm start does this automatically.***

---

### Init

Init commands are used for initializing empty file structures.

Aliases: [`init`, `i`]

__*Subcommands*__

---

#### Init Root

Generate an empty standard file structure. JSON schemas will also be generated.

`init root`

---

### Generate

Generate commands are used for generation.

Aliases: [`generate`, `g`]

__*SubCommands*__

---

#### Generate Server

Generate an new server in the root directory. Options are provided to include forge in the generated server.

`generate server <id> <version> <options>`

Options:

* `--forge <string>` Specify forge version. This is WITHOUT the minecraft version (ex. 14.23.5.2847)
  * OPTIONAL (default: null)
  * If not provided forge will not be enabled.
  * You can provide either `latest` or `recommended` to use the latest/recommended version of forge.
* `--fabric <string>` Specify fabric loader version
  * OPTIONAL (default: null)
  * If not provided fabric will not be enabled.
  * You can provide either `latest` or `recommended` to use the latest/recommended version of fabric.

> [!NOTE]  
> Forge and fabric cannot be used together on the same server. This command will fail if both are provided.

>
> Example Usage
>
> `generate server Test1 1.12.2 --forge 14.23.5.2847`
>

---

#### Generate Server from CurseForge Modpack

Generate an new server in the root directory, including files and mods from an existing CurseForge modpack.

`generate server-curseforge <id> <zipFile>`

The cursforge modpack must be downloaded as a zip and placed into `${ROOT}/modpacks/curseforge`. Pass the name of the modpack as the `<zipFile>` argument.

>
> Example Usage
>
> `generate server-curseforge WesterosCraft-Prod The+WesterosCraft+Modpack-2.1.6.zip`
>

---

#### Generate Distribution

Generate a distribution file from the root file structure.

`generate distro [name]`

Arguments:
* `name` The name of the distribution file.
  * OPTIONAL (default: `distribution`)

Options:

* `--installLocal` Have the application install a copy of the generated distribution to the Helios data folder.
  * OPTIONAL (default: false)
  * This is useful to easily test the new distribution.json in dev mode on Helios.
  * Tip: Set name to `distribution_dev` when using this option.
* `--discardOutput` Delete cached output after it is no longer required. May be useful if disk space is limited.
  * OPTIONAL (default: false)
* `--invalidateCache` Invalidate and delete existing caches as they are encountered. Requires fresh cache generation.
  * OPTIONAL (default: false)

#### Notes

As of Forge 1.13, the installer must be run to generate required files. The installer output is cached by default. This is done to speed up subsequent builds and allow Nebula to be run as a CI job. Options are provided to discard installer output (no caching) and invalidate caches (delete cached output and require fresh generation). To invalidate only a single version cache, manually delete the cached folder.

>
> Example Usage
>
> `generate distro`
>
> `generate distro distribution_dev --installLocal`
>

---

#### Generate Schemas

Generate the JSON schemas used by Nebula's internal types (ex. Distro Meta and Server Meta schemas). This command should be used to update the schemas when a change to Nebula requires it. You may need to reopen your editor for the new JSON schemas to take effect.

`generate schemas`

---

### Latest Forge

Get the latest version of Forge.

`latest-forge <version>`

---

### Recommended Forge

Get the recommended version of Forge. If no recommended build is available, it will pull the latest version.

`recommended-forge <version>`

---

## File Structure Setup (Tentative)

Nebula aims to provide users with an information preserving structure for storing files. The application will use this structure to generate a full distribution.json for HeliosLauncher. For coherency, the distribution structure is modularized and encapsulated by a directory pattern. These encapsulations will be explained below. They can be generated manually or by using the commands documented above.

### Distribution Encapsulation

The distribution object is represented by the main root. All command output will be stored in this directory. The structure is documented below.

Ex.

* `TestRoot` The root directory which encapsulates the distribution.
  * `servers` All server files are stored in this directory.

### Server Encapsulation

Server objects are encapsulated in their own folders. The name of the server's folder contains both its id and version.

Ex.

* `servers`
  * `TestServer-1.12.2` A server with id TestServer set to version 1.12.2.

The server directory will contain files pertaining to that server.

Ex.

* `TestServer-1.12.2`
  * `files` All modules of type `File`.
  * `libraries` All modules of type `Library`
  * `forgemods` All modules of type `ForgeMod`.
  * `fabricmods` All modules of type `FabricMod`.
    * This is a directory of toggleable modules. See the note below.
  * `TestServer-1.12.2.png` Server icon file.

#### Setting the Server Icon

You can set the server icon in two ways.

1. __*(Preferred)*__ Place your server icon in the root server directory as shown in the example above. Only jpg and png files will be looked at. The name of the file does not matter.
2. Paste the **full** URL to your server icon in the servermeta.json for your server. It is highly recommended to only use files that are hosted on your own servers.

The value in servermeta.json will always be used so long as it is not empty and is a [valid url](https://developer.mozilla.org/en-US/docs/Web/API/URL/URL). If it is empty or an [invalid url](https://developer.mozilla.org/en-US/docs/Web/API/URL/URL), then the first method will be used.

#### Toggleable Modules

If a directory represents a toggleable mod, it will have three subdirectories. You must filter your files into these three.

* `required` Modules that are required.
* `optionalon` Modules that are optional and enabled by default.
* `optionaloff` Modules that are optional and disabled by default.

### Additional Metadata

To preserve metadata that cannot be inferred via file structure, two files exist. Default values will be generated when applicable. Customize to fit your needs. These values should be self explanatory. If further details are required, see the [distribution.json specification document][distro.md].

#### ${ROOT}/meta/distrometa.json

Represents the additiona metadata on the distribution object.

A JSON schema is provided to assist editing this file. It should automatically be referenced when the default file is generated.

Sample:

```json
{
  "$schema": "file:///${ROOT}/schemas/DistroMetaSchema.schema.json",
  "meta": {
      "rss": "<LINK TO RSS FEED>",
      "discord": {
          "clientId": "<FILL IN OR REMOVE DISCORD OBJECT>",
          "smallImageText": "<FILL IN OR REMOVE DISCORD OBJECT>",
          "smallImageKey": "<FILL IN OR REMOVE DISCORD OBJECT>"
      }
  }
}
```

#### servers/${YOUR_SERVER}/servermeta.json

Represents the additional metadata on the server object (for a YOUR_SERVER).

A JSON schema is provided to assist editing this file. It should automatically be referenced when the default file is generated.

Sample:

```json
{
  "$schema": "file:///${ROOT}/schemas/ServerMetaSchema.schema.json",
  "meta": {
    "version": "1.0.0",
    "name": "Test (Minecraft 1.12.2)",
    "description": "Test Running Minecraft 1.12.2 (Forge v14.23.5.2854)",
    "icon": "How to set the server icon: https://github.com/dscalzi/Nebula#setting-the-server-icon",
    "address": "localhost:25565",
    "discord": {
      "shortId": "1.12.2 Test Server",
      "largeImageText": "1.12.2 Test Server",
      "largeImageKey": "seal-circle"
    },
    "mainServer": false,
    "autoconnect": true
  },
  "forge": {
    "version": "14.23.5.2854"
  },
  "untrackedFiles": []
}
```

#### Untracked Files

Untracked files is optional. MD5 hashes will not be generated for files matching the provided glob patterns. The launcher will not validate/update files without MD5 hashes.

```json
{
  "untrackedFiles": [
    {
      "appliesTo": ["files"],
      "patterns": [
        "config/*.cfg",
        "config/**/*.yml"
      ]
    }
  ]
}
```

In the above example, all files of type `cfg` in the config directory will be untracked. Additionally, all files of type `yml` in the config directory and its subdirectories will be untracked. You can tweak these patterns to fit your needs, this is purely an example. The patterns will only be applied to the folders specified in `appliesTo`. As an example, valid values include `files`, `forgemods`, `libraries`, etc.

```json
{
  "untrackedFiles": [
    {
      "appliesTo": ["files"],
      "patterns": [
        "config/*.cfg",
        "config/**/*.yml"
      ]
    },
    {
      "appliesTo": ["forgemods"],
      "patterns": [
        "optionalon/*.jar"
      ]
    }
  ]
}
```

Another example where all `optionalon` forgemods are untracked. **Untracking mods is NOT recommended. This is an example ONLY.**

### Note on JSON Schemas

The `$schema` property in a JSON file is a URL to a JSON schema file. This property is optional. Nebula provides schemas for internal types to make editing the JSON easier. Editors, such as Visual Studio Code, will use this schema file to validate the data and show useful information, like property descriptions. Valid properties will also be autocompleted. For detailed information, you may view the [JSON Schema Website][jsonschemawebsite].

Nebula will store JSON schemas in `${ROOT}/schemas`. This is so that they will always be in sync with your local version of Nebula. They will initially be generated by the `init root` command. To update the schemas, you can run the `generate schemas` command.


[dotenvnpm]: https://www.npmjs.com/package/dotenv
[distro.md]: https://github.com/dscalzi/HeliosLauncher/blob/master/docs/distro.md
[jsonschemawebsite]: https://json-schema.org/
