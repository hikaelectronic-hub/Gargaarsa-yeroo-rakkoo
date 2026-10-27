const $=id=>document.getElementById(id);
const translations={
om:{app:"Gargaarsa Yeroo Rakkoo",intro:"Yeroo rakkoo keessa jirtu, nama ati amanattu saffisaan beeksisi.",need:"Gargaarsa hatattamaa barbaaddaa?",hint:"SOS tuqi. Ergaa fi bilbila osoo hin ergin dura mirkaneessa argatta.",contacts:"Namoota amanamoo",name:"Maqaa",phone:"Lakkoofsa bilbilaa (+251...)",save:"Kuusi",quick:"Bilbila hatattamaa",numberNote:"Lakkoofsa naannoo kee mirkaneeffadhu; lakkoofsa sirrii hin beekne hin tilmaamin.",emergencyNumber:"Lakkoofsa hatattamaa naannoo kee",call:"Bilbili",nearby:"Gargaarsa naannoo kee",nearbyNote:"Kaartaa irratti tajaajila naannoo kee barbaadi. Bu'aan argamu mirkanaa'uu qaba.",health:"Hospitaala",police:"Poolisii",fire:"Ibidda / Fayyisummaa"},
en:{app:"Emergency Help",intro:"Quickly alert someone you trust when you are in trouble.",need:"Do you need urgent help?",hint:"Press SOS. You will confirm before opening a message or call.",contacts:"Trusted contacts",name:"Name",phone:"Phone number (+country code)",save:"Save",quick:"Emergency call",numberNote:"Verify your local emergency number; do not guess it.",emergencyNumber:"Your verified local emergency number",call:"Call",nearby:"Nearby help",nearbyNote:"Search local services on a map. Verify results before relying on them.",health:"Hospital",police:"Police",fire:"Fire / Rescue"}
};
let contacts=JSON.parse(localStorage.getItem("trustedContacts")||"[]"), locationText="";
function renderContacts(){ $("contactList").innerHTML=""; contacts.forEach((c,i)=>{const li=document.createElement("li");li.textContent=`${c.name}: ${c.phone} `;const b=document.createElement("button");b.textContent="✕";b.onclick=()=>{contacts.splice(i,1);persist()};li.append(b);$("contactList").append(li)})}
function persist(){localStorage.setItem("trustedContacts",JSON.stringify(contacts));renderContacts();updateTrustedCall()}
function updateTrustedCall(){const a=$("callTrusted");const c=contacts[0];a.href=c?`tel:${c.phone}`:"#";a.classList.toggle("disabled",!c);a.setAttribute("aria-disabled",String(!c));a.textContent=c?`📞 ${c.name} bilbili`:"📞 Nama amanamaa bilbili"}
$("save").onclick=()=>{const name=$("contactName").value.trim(),phone=$("contactPhone").value.trim();if(!name||!/^\+?[0-9\s()-]{7,20}$/.test(phone)){alert("Maqaa fi lakkoofsa bilbilaa sirrii galchi.");return}contacts.push({name,phone});$("contactName").value="";$("contactPhone").value="";persist()};
$("emergencyNumber").addEventListener("input",()=>{const n=$("emergencyNumber").value.replace(/[^+0-9]/g,"");$("callEmergency").href=n?`tel:${n}`:"#";$("callEmergency").classList.toggle("disabled",!n);$("callEmergency").setAttribute("aria-disabled",String(!n))});
function mapLinks(lat,lon){["health","police","fire"].forEach((id,i)=>{const terms=["hospital","police station","fire station"][i];$(id).href=`https://www.openstreetmap.org/search?query=${encodeURIComponent(terms+" near "+lat+","+lon)}`})}
async function getLocation(){return new Promise(resolve=>{if(!navigator.geolocation){resolve(null);return}navigator.geolocation.getCurrentPosition(p=>resolve({lat:p.coords.latitude,lon:p.coords.longitude}),()=>resolve(null),{enableHighAccuracy:true,timeout:10000,maximumAge:30000})})}
$("sos").onclick=async()=>{if(!contacts.length){$("status").textContent="Duraan maqaa fi lakkoofsa nama amanamaa tokkoo galchi.";return}
if(!confirm("SOS ergaa qopheessuuf itti fufuu barbaaddaa?"))return;
$("status").textContent="Bakka kee barbaadaa...";
const pos=await getLocation();locationText=pos?`Bakka koo: https://www.openstreetmap.org/?mlat=${pos.lat}&mlon=${pos.lon}#map=17/${pos.lat}/${pos.lon}`:"Bakka koo argachuun hin danda'amne.";
if(pos)mapLinks(pos.lat,pos.lon);
const body=encodeURIComponent(`GARGAARSA HATATTAMAA BARBAADA! ${locationText}`);
const phones=contacts.map(c=>c.phone).join(",");
$("status").textContent="Ergaan qophaa'eera. Erguuf appii SMS keessatti mirkaneessi.";
window.location.href=`sms:${phones}?body=${body}`;
};
$("language").onchange=e=>{const t=translations[e.target.value];document.querySelectorAll("[data-i18n]").forEach(el=>{const k=el.dataset.i18n;if(t[k])el.textContent=t[k]});document.documentElement.lang=e.target.value};
renderContacts();updateTrustedCall();

// Browser audio recording. Sharing is user-initiated; unsupported browsers can download the recording.
let mediaRecorder=null, audioChunks=[], audioBlob=null, audioUrl=null;
const recordBtn=$("recordVoice"), stopBtn=$("stopVoice"), shareBtn=$("shareVoice"), voiceStatus=$("voiceStatus"), preview=$("voicePreview");
recordBtn.onclick=async()=>{
  if(!navigator.mediaDevices?.getUserMedia || !window.MediaRecorder){voiceStatus.textContent="Browser kee sagalee waraabuu hin deeggaru. Chrome haaraa fayyadami.";return;}
  try{
    const stream=await navigator.mediaDevices.getUserMedia({audio:true});
    audioChunks=[];mediaRecorder=new MediaRecorder(stream);
    mediaRecorder.ondataavailable=e=>{if(e.data.size)audioChunks.push(e.data)};
    mediaRecorder.onstop=()=>{audioBlob=new Blob(audioChunks,{type:mediaRecorder.mimeType||"audio/webm"});if(audioUrl)URL.revokeObjectURL(audioUrl);audioUrl=URL.createObjectURL(audioBlob);preview.src=audioUrl;preview.hidden=false;shareBtn.disabled=false;stream.getTracks().forEach(t=>t.stop());voiceStatus.textContent="Sagaleen waraabameera. Amma qoodi."};
    mediaRecorder.start();recordBtn.disabled=true;stopBtn.disabled=false;voiceStatus.textContent="Sagalee waraabamaa jira...";
  }catch(e){voiceStatus.textContent="Hayyama microphone hin arganne. Settings browser keessaa microphone hayyami.";}
};
stopBtn.onclick=()=>{if(mediaRecorder?.state==="recording"){mediaRecorder.stop();recordBtn.disabled=false;stopBtn.disabled=true}};
shareBtn.onclick=async()=>{if(!audioBlob)return;const file=new File([audioBlob],"gargaarsa-sagalee.webm",{type:audioBlob.type});try{if(navigator.canShare?.({files:[file]})){await navigator.share({files:[file],title:"Gargaarsa Yeroo Rakkoo",text:"Sagalee gargaarsaa"});}else{const a=document.createElement("a");a.href=audioUrl;a.download=file.name;a.click();voiceStatus.textContent="Sagaleen buufameera. Amma WhatsApp ykn SMS irratti faayila kana maxxansi."}}catch(e){if(e.name!=="AbortError")voiceStatus.textContent="Qooduun hin milkoofne. Sagalee buufachuun yaali."}}

if ('serviceWorker'  in navigator && location.protocol.startsWith('http')) { window.addEventListener('load',()=>navigator.serviceWorker.register('./sw.js').catch(()=>{})); }
