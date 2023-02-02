import { WebSocketServer } from 'ws';
import chokidar from "chokidar";
import fs from "fs/promises";
import { resolve } from 'path';
import launch from 'launch-editor'

const pathToPosix = (path) => path.replace(/\\/g, "/");

const wss = new WebSocketServer({ port: 8080 });
let initialFilesSynced = false

const delay = async (duration) => new Promise(resolve => setTimeout(resolve, duration)) 

let prevSocket
wss.on('connection', (socket) => {
  // For now we allow only one active connection.
  prevSocket?.close()
  prevSocket = socket

  socket.on('message', async (buffer) => {
    const data = JSON.parse(new TextDecoder().decode(buffer))

    if (data.method === 'deviceConnected' && !initialFilesSynced) {
      for (let path of filesToSync) {
        syncFile(path, false)
        console.log('sync', path)
        // Todo: make `syncFile` async and get rid of `delay()` workaround.
        await delay(200)
      }
      initialFilesSynced = true
      return
    }

    if (data.method === 'launchEditor') {
      const file = data.file.replace(/^lua\//, 'src/')
      launch(file, 'code')
    }
  })

  const syncFile = async (path, update = true) => {
    path = pathToPosix(path);
    const content = await fs.readFile(resolve('src', path), "utf8")
    const method = update ? 'updateFile' : 'writeFile'
    socket.send(JSON.stringify({ method, params: { path, content } }))
  }

  const watcher = chokidar.watch("**/*", { cwd: resolve(process.cwd(), 'src')});
  watcher.on("change", syncFile);
  
  const filesToSync = [];
  const handleInitialAdd = (path) => filesToSync.push(path);
  watcher.on("add", handleInitialAdd);
  watcher.on("ready", async () => watcher.off("add", handleInitialAdd));
})