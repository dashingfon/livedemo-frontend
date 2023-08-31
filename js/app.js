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








