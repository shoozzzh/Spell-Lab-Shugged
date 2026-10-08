const chokidar = require("chokidar");
const fs = require("fs");
const path = require("path");

const watchedPath = "./files"
const genFileName = "files_used_ph.lua"

let clearAndExit = false;
if (clearAndExit) {
    for (const entryName of fs.readdirSync(watchedPath)) {
        const entryPath = path.join(watchedPath, entryName);
        if (fs.statSync(entryPath).isDirectory()) {
            let genFile = path.join(entryPath, genFileName)
            if (fs.existsSync(genFile)) {
                fs.unlinkSync(genFile);
            }
        }
    }
}

const moduleMap = new Map()

const top_level_fake_module = "__TOP_LEVEL__"

let ready = false;

function getModuleFileSet(moduleName) {
    if (!moduleMap.has(moduleName)) {
        moduleMap.set(moduleName, new Set())
    }
    return moduleMap.get(moduleName)
}

function formatGenFile(list, isTopLevel) {
    let result = "return {\n";
    list.forEach(element => {
        let short
        if (isTopLevel) {
            short = element.match(/files[\/\\](.*)/)
        } else {
            short = element.match(/files[\/\\]\w+[\/\\](.*)/)
        }
        if (short === null) {
            console.error(`Cannot extract short path from ${element}`)
            return
        }
        result += '    "' + short[1].replaceAll("\\", "/") + '",\r\n';
    });
    result += "}\r\n";
    return result
}

function updateModuleIfReady(moduleName) {
    if (!ready) { return; }
    let isTopLevel = moduleName === top_level_fake_module
    let modulePath
    if (isTopLevel) {
        modulePath = watchedPath
    } else {
        modulePath = path.join(watchedPath, moduleName);
    }
    let fileSet = getModuleFileSet(moduleName)
    if (fileSet.size > 0) {
        fs.writeFileSync(path.join(modulePath, genFileName), formatGenFile(fileSet, isTopLevel));
    } else {
        fs.unlinkSync(path.join(modulePath, genFileName))
    }
    console.log(`writing into ${path.join(modulePath, genFileName)}`)
}

function findModule(file) {
    let result = file.match(/files[\/\\](\w+)[\/\\]/)
    if (result !== null) {
        return result[1]
    }

    if (/files[\/\\]\w+\.\w+$/.test(file)) {
        return top_level_fake_module
    }

    return null
}

function checkFile(file) {
    const data = fs.readFileSync(file, { encoding: 'utf-8' });
    return data.search("%") !== -1;
}

function updateFile(file) {
    const moduleName = findModule(file);
    if (moduleName === null) return;
    if (checkFile(file)) {
        getModuleFileSet(moduleName).add(file);
        updateModuleIfReady(moduleName)
    }
}

let watcher = chokidar.watch(watchedPath, {
    ignored: (file, _stats) => _stats?.isFile() && !(file.endsWith('.lua') || file.endsWith('.xml')),
    interval: 1000,
});

watcher
    .on('add', (file, stat) => {
        console.log(`adding ${file}`)
        updateFile(file);
    })
    .on('change', (file, stat) => {
        updateFile(file);
    })
    .on('unlink', (file, stat) => {
        const moduleName = findModule(file);
        if (getModuleFileSet(moduleName).delete(file)) {
            updateModuleIfReady(moduleName)
        }
    })
    .on('ready', () => {
        ready = true
        console.log(`${moduleMap.size} modules found`)
        for (let [moduleName, fileSet] of moduleMap) {
            console.log(`${moduleName}:`)
            console.log(fileSet)
            if (fileSet.size > 0) {
                updateModuleIfReady(moduleName)
            }
        }
    })
