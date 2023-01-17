import { WebSocketServer } from 'ws';
import chokidar from "chokidar";
import fs from "fs/promises";
import { resolve } from 'path';

const pathToPosix = (path) => path.replace(/\\/g, "/");

const wss = new WebSocketServer({ port: 8080 });
let initialFilesSynced = false

wss.on('connection', (ws) => {
  ws.on('message', (buffer) => {
    const data = JSON.parse(new TextDecoder().decode(buffer))
    if (data.method === 'deviceConnected' && !initialFilesSynced) {
      for (let path of filesToSync) syncFile(path, false)
      initialFilesSynced = true
    }
  })

  const syncFile = async (path, update = true) => {
    path = pathToPosix(path);
    const content = await fs.readFile(resolve('src', path), "utf8")
    const method = update ? 'updateFile' : 'writeFile'
    ws.send(JSON.stringify({ method, params: { path, content } }))
  }

  const watcher = chokidar.watch("**/*", { cwd: resolve(process.cwd(), 'src')});
  watcher.on("change", syncFile);
  
  const filesToSync = [];
  const handleInitialAdd = (path) => filesToSync.push(path);
  watcher.on("add", handleInitialAdd);
  watcher.on("ready", async () => watcher.off("add", handleInitialAdd));
})