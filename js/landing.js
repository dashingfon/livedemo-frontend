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

    
const createDaoButton = document.getElementById("createDaoButton");
const createDaoButton1 = document.getElementById("createDaoButton1");
const popup = document.getElementById("popup");
const closePopup = document.getElementById("closePopup");
const daoForm = document.getElementById("daoForm");
const submitFormButton = document.getElementById("submitForm");
const submissionDateField = document.getElementById("submissionDate");


// create dao form
createDaoButton.addEventListener("click", () => {
  popup.style.display = "block";
});

createDaoButton1.addEventListener("click", () => {
  popup.style.display = "block";
});

closePopup.addEventListener("click", () => {
  popup.style.display = "none";
});


// submit form
submitFormButton.addEventListener("click", async (event) => {
  event.preventDefault();

   // Get the current date and time
  const currentDate = new Date();

  // Format the date as desired (e.g., "YYYY-MM-DD HH:MM:SS")
  const formattedDate = currentDate.toISOString().split("T")[0];

    // Set the value of the submissionDate field
  submissionDateField.value = formattedDate;

  const formData = new FormData(daoForm);
  const formDataObject = {}; // Initialize the formDataObject

  for (const [name, value] of formData.entries()) {
    formDataObject[name] = value;
  }

  const formDataString = JSON.stringify(formDataObject);
  sessionStorage.setItem("formData", formDataString);

//   Display a success message
const successMessage = document.createElement("p");
  successMessage.textContent = "DAO created successfully!";
  successMessage.style.color = "green";
  daoForm.appendChild(successMessage);

  

//   Delay for a moment to show the success message
  await new Promise((resolve) => setTimeout(resolve, 2000));

  // Navigate to the next page (replace 'nextPage.html' with the actual URL)
  window.location.href = "dao.html";
});



// add new element with button
const addMemberButton = document.getElementById("addMemberButton");
const removeMemberButton = document.getElementById("removeMemberButton");
const newMember = document.getElementById("dynamicMemberFields");

let memberCounter = 3;

removeMemberButton.addEventListener("click", (event) => {
    event.preventDefault();
  const newMembers = newMember.getElementsByClassName("new-member");

   if (newMembers.length >= 4) {
    const numToRemove = 4; // Number of members to remove
    for (let i = 0; i < numToRemove; i++) {
      newMembers[newMembers.length - 1].remove(); // Remove the last added member
    }

    memberCounter--;

    // Disable the remove button if no new members are left
    if (newMembers.length === 0) {
      removeMemberButton.disabled = true;
    }
  }
});

addMemberButton.addEventListener("click", (event) => {
    
event.preventDefault();
  const newNewMember = createNewMember(); // Create the new member fields

  // Enable the remove button when at least one new member is added
  removeMemberButton.disabled = false;
});

function createNewMember() {

  memberCounter++;

  // Create new elements for the member fields
  const newMemberLabel = document.createElement("label");
  newMemberLabel.setAttribute("for", `foundingMember${memberCounter}`);
  newMemberLabel.textContent = `${memberCounter}) Founding Member Address:`;
  newMemberLabel.classList.add("new-member"); 

  const newMemberInput = document.createElement("input");
  newMemberInput.setAttribute("type", "text");
  newMemberInput.setAttribute("id", `foundingMember${memberCounter}`);
  newMemberInput.setAttribute("name", `foundingMember${memberCounter}`);
  newMemberInput.setAttribute("required", true);
  newMemberInput.classList.add("new-member"); // Add a class for identifying new members

  const newAllocationLabel = document.createElement("label");
  newAllocationLabel.setAttribute("for", `allocation${memberCounter}`);
  newAllocationLabel.textContent = "Percent Allocation:";
  newAllocationLabel.classList.add("new-member"); 

  const newAllocationInput = document.createElement("input");
  newAllocationInput.setAttribute("type", "number");
  newAllocationInput.setAttribute("id", `allocation${memberCounter}`);
  newAllocationInput.setAttribute("name", `allocation${memberCounter}`);
  newAllocationInput.setAttribute("required", true);
  newAllocationInput.setAttribute("style", "margin-bottom: 20px");
  newAllocationInput.classList.add("new-member"); // Add a class for identifying new members



  // Append the new elements to a container div
  newMember.classList.add("new-member");
  newMember.appendChild(newMemberLabel);
  newMember.appendChild(newMemberInput);
  newMember.appendChild(newAllocationLabel);
newMember.appendChild(newAllocationInput);

  return newMember;
}
