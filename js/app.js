// web3 connect functionality
 const loginButton = document.getElementById('login-button');

    loginButton.addEventListener('click', connectToMetaMask);

    async function connectToMetaMask() {
  try {
    if (typeof window.ethereum !== 'undefined') {
      
      loginButton.textContent = 'Connecting...';
      
      // Request access to accounts
      const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
      if (accounts.length > 0) {
   
    const truncatedAddress = accounts[0].slice(0, 8); 

   
    loginButton.textContent = `Connected: ${truncatedAddress}...`;
    loginButton.disabled = true;
}
    } else {
      
      loginButton.textContent = 'MetaMask Not Detected';
      loginButton.style.backgroundColor = 'red';
    }
  } catch (error) {
    
    console.error('Error connecting to MetaMask:', error);
    loginButton.textContent = 'Connection Failed';
    loginButton.style.backgroundColor = 'red';
  }
}




// Retrieve the JSON string from SessionStorage on the next page
const formDataString2 = sessionStorage.getItem("formData");

if (formDataString2) {
  // Convert the JSON string to an object
  const formDataObject2 = JSON.parse(formDataString2);

  console.log(formDataObject2);

  const daoName = formDataObject2["daoName"];
const daoDescription = formDataObject2["daoDescription"];
const dateCreated = formDataObject2["submissionDate"];
const communityLink = formDataObject2["chatLink"];

// Update the DOM with the retrieved values
  const daoNameElement = document.getElementById("daoName");
  const daoDescriptionElement = document.getElementById("daoDescription");
  const dateCreatedElement = document.getElementById("dateCreated");
  const communityLinkElement = document.getElementById("chatLink");

  daoNameElement.textContent = daoName;
  daoDescriptionElement.textContent = daoDescription;
  dateCreatedElement.textContent = dateCreated;
  communityLinkElement.textContent =communityLink;


  // You can now access the form data using the keys in formDataObject2
} else {
  console.log("Form data not found in sessionStorage.");
}



