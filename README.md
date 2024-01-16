Do you like organizing your services but wish there was an easy way for services to depend on each other?

<h1>Introducing Karen, the library specifically for speaking to your managers!</h1>

Taking inspiration from [C# .Net service registration](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/dependency-injection?view=aspnetcore-8.0) and [Kotlin's Jetpack Startup library](https://developer.android.com/topic/libraries/app-startup), this library allows you to explicitly register your services and their dependencies, while handling initialization order for you, access your initialized services globally, and manage dependency injection for tests.

<h2> Installation</h2>
<details>
<summary>With Wally</summary>

Add <a href="https://wally.run/package/kylaaa/karen">Karen</a> to the dependencies section of your wally.toml file.

```
[dependencies]
Karen = "kylaaa/karen@0.1.5"
```
</details>
<details>
<summary>From GitHub</summary>

1) Goto the [Karen GitHub repo](https://github.com/Kylaaa/Karen).
1) Download the latest `Karen.rbxm` from the Releases section.
1) Drag it into Roblox Studio from your Downloads folder.

</details>

<h2> Usage </h2>
<details>
<summary>Creating singleton classes </summary>

```lua
local A = {}
A.__index = A
function A.new(dependencies : {})
    -- use dependencies to initialize the service
    local B = dependencies.B

    return setmetatable({ 
        -- optionally store the dependencies table for later
        -- dependencies = dependencies
    }, A)
end

function A:foo()
    print("Hello world")
    -- use dependent services inside function calls
    -- self.dependencies.B:bar(123)
end
```
</details>

<details open>
<summary>Intializing all of your singletons</summary>

At the entry point to your code, initialize all of the implementations for your singletons.

```lua
local Packages = game.ReplicatedStorage.Packages -- your path to where packages are stored
local Karen = require(Packages.Karen)

local ManagersFolder = script.Parent.Managers  --your path to where you store your singleton ModuleScripts

-- initialize the singleton manager
local sm = Karen.new()

-- register each singleton by passing the ModuleScript Instance along with a list of its dependencies
sm:registerSingleton(ManagersFolder.A, {
    ManagersFolder.B
})
sm:registerSingleton(ManagersFolder.B, {
    ManagersFolder.C,
    ManagersFolder.D
})
sm:registerSingleton(ManagersFolder.C, {})
sm:registerSingleton(ManagersFolder.D, {})

-- tell the manager to initialize all of the singletons with their dependencies
sm:initialize()
```
</details>

<details>
<summary>Accessing registered singletons</summary>

```lua
-- simply use the string name of the ModuleScript to access the initialized singleton
sm:get("A"):foo()
-- or
Karen.getInstance():get("A"):foo()
```
</details>

<h2> How Is this useful? </h2>

As projects get larger, having logic cleanly divided into testable chunks becomes more and more important. And having services with cleanly defined interfaces allows for that functionality to be easily mocked for tests.

A simple use case would be to have a LogManager whose sole job is to allow for messages to be logged at varying levels, and every service uses it instead of using `print` or `warn` statements. Then from a single place, you can change how these messages are displayed throughout the entire game.

<details>
<summary>Example LogManager </summary>

```lua
local LibraryRoot = script:FindFirstAncestor("TwitchBlox")

local Packages = LibraryRoot.Packages
local Signal = require(Packages.Signal)


local LogManager = {}
LogManager.__index = LogManager

LogManager.LogLevel = {
    None = 0,
    Error = 1,
    Warning = 2,
    Message = 3,
    Trace = 4,
}

function LogManager.new(dependencies : {})
    local cm = dependencies.ConfigurationManager

    local lm = {
        logLevel = cm:getValue("LOGGING_LEVEL"),
        NewMessage = Signal.new(), -- (logLevel : number, ... : any) -> ()
    }
    setmetatable(lm, LogManager)

    cm.Updated:Connect(function()
        lm.LogLevel = cm:getValue("LOGGING_LEVEL")
    end)

    return lm
end

function LogManager:log(level : number, ...)
    assert(level ~= LogManager.LogLevel.None, "level cannot be `None`")

    if level <= self.LogLevel then
        self.NewMessage:fire(level, ...)
    end
end

function LogManager:error(...)
    self:log(LogManager.Error, ...)
end

function LogManager:warn(...)
    self:log(LogManager.Warning, ...)
end

function LogManager:message(...)
    self:log(LogManager.Message, ...)
end

function LogManager:trace(...)
    self:log(LogManager.Trace, ...)
end

return LogManager
```

</details>

