// const userID = document.getElementById('user-id');

// var _userID;

// supposed to be gotten from the backend
// _userID = "0xC963…9d01";

// userID.innerText = _userID;

// console.log(userID.innerText);

 const textElement = document.getElementById('text');
    const seeMoreButton = document.getElementById('read-more');

    seeMoreButton.addEventListener('click', () => {
      if (textElement.style.height === '4.3rem') {
        textElement.style.height= 'auto'; // Display full text
        seeMoreButton.textContent = 'See Less';
      } else {
        textElement.style.height = '4.3rem'; // Display limited text
        seeMoreButton.textContent = '...Read More';
      } // Hide the "See More" button
    });
