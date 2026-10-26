// Optional development tool: requires Playwright and a local Edge installation.
const fs=require('node:fs/promises');
const path=require('node:path');
const {chromium}=require('playwright');
const root=path.resolve(__dirname,'..');
(async()=>{
  const out=path.join(root,'docs','evidence'); await fs.mkdir(out,{recursive:true});
  const browser=await chromium.launch({channel:'msedge',headless:true});
  try {
    const page=await browser.newPage({viewport:{width:1280,height:1050},deviceScaleFactor:1});
    const errors=[]; page.on('pageerror',e=>errors.push(e.message));
    await page.goto(process.env.COURSE_RECOMMENDER_URL||'http://127.0.0.1:8001',{waitUntil:'networkidle'});
    await page.locator('#query').fill('Quiero aprender a analizar ventas con SQL y tengo conocimientos básicos');
    await page.locator('#level').selectOption('Beginner');
    await page.locator('#submit').click();
    await page.waitForFunction(()=>document.querySelector('#status').textContent.includes('cursos ordenados'),{},{timeout:120000});
    await page.screenshot({path:path.join(out,'search.png')});
    const response=page.waitForResponse(r=>r.url().endsWith('/api/rag'),{timeout:240000});
    await page.locator('#rag-submit').click();
    const data=await (await response).json();
    if(!data.generated||!data.citations?.length) throw Error(JSON.stringify(data));
    await page.locator('#rag-panel').waitFor({state:'visible',timeout:240000});
    await page.screenshot({path:path.join(out,'rag-screen.png')});
    await page.locator('#rag-panel').screenshot({path:path.join(out,'rag-answer.png')});
    await page.locator('#rag-panel summary').click();
    await page.locator('#rag-panel').screenshot({path:path.join(out,'rag-context.png')});
    await fs.writeFile(path.join(out,'ui-rag.json'),JSON.stringify(data,null,2),'utf8');
    await fs.writeFile(path.join(out,'http-validation.json'),JSON.stringify({search:true,rag:true,citations:data.citations,browserErrors:errors},null,2));
    if(errors.length) throw Error(errors.join('\n'));
    console.log('HTTP, interfaz, contexto y capturas OK');
  } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1});
