// const userID = document.getElementById('user-id');

// var _userID;

// supposed to be gotten from the backend
// _userID = "0xC963…9d01";

// userID.innerText = _userID;

// console.log(userID.innerText);


// read more read less ui
 const textElement = document.getElementById('text');
    const seeMoreButton = document.getElementById('read-more');

    seeMoreButton.addEventListener('click', () => {
      if (textElement.style.height === '4.3rem') {
        textElement.style.height= 'auto';
        seeMoreButton.textContent = 'See Less';
      } else {
        textElement.style.height = '4.3rem'; 
        seeMoreButton.textContent = '...Read More';
      } 
    });

// toggle element ui
   const meetOurTeam = document.getElementById('meet-our-team');
   const ourTeam = document.getElementById('our-team');
   const teamPics = document.getElementById('team-pics');
    
    // const teamContent = document.getElementById('team-content');

    let isExpanded = true;

    meetOurTeam.addEventListener('click', () => {
      if (isExpanded) {
        meetOurTeam.style.display = 'none';
        ourTeam.style.display = 'block';
        teamPics.style.display = 'flex';
      } else {
         meetOurTeam.style.display = 'block';
        ourTeam.style.display = 'none';
        teamPics.style.display = 'none';
      }
      isExpanded = !isExpanded;
    });

    ourTeam.addEventListener('click', () => {
      if (isExpanded) {
        meetOurTeam.style.display = 'none';
        ourTeam.style.display = 'block';
        teamPics.style.display = 'flex';
      } else {
         meetOurTeam.style.display = 'block';
        ourTeam.style.display = 'none';
        teamPics.style.display = 'none';
      }
      isExpanded = !isExpanded;
    });