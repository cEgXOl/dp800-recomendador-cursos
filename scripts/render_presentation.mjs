import fs from 'node:fs/promises';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const {PresentationFile,FileBlob}=await import(pathToFileURL(path.join(process.env.RUNTIME_NODE_MODULES,'@oai/artifact-tool/dist/artifact_tool.mjs')).href);
const root=process.cwd(), out=path.join(root,'tmp','final-slides');
await fs.mkdir(out,{recursive:true});
const deck=await PresentationFile.importPptx(await FileBlob.load(path.join(root,'presentation','dp800-project.pptx')));
for(const [i,slide] of deck.slides.items.entries()){
    const blob=await deck.export({slide,format:'png',scale:1});
    await fs.writeFile(path.join(out,`slide-${i+1}.png`),new Uint8Array(await blob.arrayBuffer()));
}
console.log('Final slides rendered:',deck.slides.items.length);
