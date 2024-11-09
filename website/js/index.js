const counter = document.querySelector(".counter-number");
async function updateCounter() {
    let response = await fetch("https://b3g5yynctk27w75hdeb35oasay0gmihw.lambda-url.us-east-1.on.aws/")
    let data = await response.json();
    counter.innerHTML = ` Views: ${data}`;
}




