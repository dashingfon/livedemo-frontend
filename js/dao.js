// Retrieve the JSON string from SessionStorage on the next page
const formDataString2 = sessionStorage.getItem("formData");

const newMemberFormDataString2 = sessionStorage.getItem("newMemberFormData");

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

//   members list ui
  const memberTileElement = document.getElementById("memberTile");
//   const memberAvatarElement = document.getElementById("memberAvatar");  
  const membersListElement = document.getElementById("membersList");

  const members = [];
//   let totalAllocation = 0;

  for (let i = 1; formDataObject2[`foundingMember${i}`]; i++) {
    const memberAddress = formDataObject2[`foundingMember${i}`];
    const allocation = formDataObject2[`allocation${i}`];

    members.push({ address: memberAddress, allocation: allocation });

    // total allocation
    // totalAllocation += parseInt(allocation);
  }

  const memberCountElement = document.getElementById("memberCount");
  memberCountElement.textContent = members.length;



  for (const member of members) {
   
    const newMemberTile = memberTileElement.cloneNode(true);

    const memberAddressElement = newMemberTile.querySelector("#memberAddress");
  const percentAllocationElement = newMemberTile.querySelector("#percentAllocation");

   memberAddressElement.textContent = member.address;
  percentAllocationElement.textContent = member.allocation + '%' ;

        percentAllocationElement.style.background = 'rgba(82, 255, 0, 0.15)';



    membersListElement.appendChild(newMemberTile);

    memberTileElement.remove();
  }

  daoNameElement.textContent = daoName;
  daoDescriptionElement.textContent = daoDescription;
  dateCreatedElement.textContent = dateCreated;
  communityLinkElement.textContent =communityLink;


  // You can now access the form data using the keys in formDataObject2
} else {
  console.log("Form data not found in sessionStorage.");
}



// create new member from add member
if (newMemberFormDataString2) {
  const newMemberFormDataObject2 = JSON.parse(newMemberFormDataString2);

  console.log(newMemberFormDataObject2);

  const memberTileElement = document.getElementById("memberTile");
//   const memberAvatarElement = document.getElementById("memberAvatar");  
  const membersListElement = document.getElementById("membersList");

  const newMemberAddress = newMemberFormDataObject2["newMemberAddress"]

  const newMemberAllocation = newMemberFormDataObject2["newMemberPercentAllocation"]

  const newMemberTile = memberTileElement.cloneNode(true)

   const memberAddressElement = newMemberTile.querySelector("#memberAddress");
  const percentAllocationElement = newMemberTile.querySelector("#percentAllocation");

     memberAddressElement.textContent = newMemberAddress;
  percentAllocationElement.textContent = newMemberAllocation + '%' ;

        percentAllocationElement.style.background = 'rgba(82, 255, 0, 0.15)';

  membersListElement.appendChild(newMemberTile);

    const memberCountElement = document.getElementById("memberCount");

  console.log(memberCountElement.textContent);

const currentCount = parseInt(memberCountElement.textContent);
memberCountElement.textContent = currentCount + 1;


  console.log(memberCountElement.textContent);
}




// add new members
const addMemberButton = document.getElementById("addMember");
const addMemberPopUp = document.getElementById("popupAddMember");
const closeAddMember = document.getElementById("closeAddMemberFormIcon");
const submitNewMemberForm = document.getElementById("submitNewMemberForm");
const addMemberForm = document.getElementById("addMemberForm")



addMemberButton.addEventListener("click", () => {
 addMemberPopUp.style.display = "block";
});



closeAddMember.addEventListener("click", ()=>{
      addMemberPopUp.style.display = "none";
});

submitNewMemberForm.addEventListener("click", async (event)=>{
event.preventDefault();
const newMemberFormData = new FormData(addMemberForm);
const newMemberFormDataObject = {}

for (const [name, value] of newMemberFormData.entries()) {
  newMemberFormDataObject[name] = value;
}

const newMemberFormDataString = JSON.stringify(newMemberFormDataObject);
sessionStorage.setItem("newMemberFormData", newMemberFormDataString);

const successMessage = document.createElement("p");
  successMessage.textContent = "member Added successfully!";
  successMessage.style.color = "green";
  addMemberForm.appendChild(successMessage);
 

//   Delay for a moment to show the success message
  await new Promise((resolve) => setTimeout(resolve, 2000));

    window.location.href = "dao.html";

});


// graph dropdowns
const header2 = document.getElementById("header2");
const dropdownIcon2 = document.getElementById("dropdownIcon2");
const backupIcon2 = document.getElementById("backupIcon2");
const graphDropdown2 = document.getElementById("graphDropdown2");

header2.addEventListener("click", () => {
  graphDropdown2.style.display = graphDropdown2.style.display === "none" ? "flex" : "none";
  dropdownIcon2.style.display = dropdownIcon2.style.display === "none" ? "flex" : "none";
  backupIcon2.style.display = backupIcon2.style.display === "none" ? "flex" : "none";
});


const header = document.getElementById("header");
const dropdownIcon = document.getElementById("dropdownIcon");
const backupIcon = document.getElementById("backupIcon");
const graphDropdown = document.getElementById("graphDropdown");

header.addEventListener("click", () => {
  graphDropdown.style.display = graphDropdown.style.display === "none" ? "flex" : "none";
  dropdownIcon.style.display = dropdownIcon.style.display === "none" ? "flex" : "none";
  backupIcon.style.display = backupIcon.style.display === "none" ? "flex" : "none";
});



// graph functionality 
// Sample data (replace with your actual data)
const data = {
  labels: ["Aug 1", "Aug 7", "Aug 14", "Aug 21", "Aug 31",],
  proposals: [0, 0, 0, 0, 0],
  members: [0, 0, 0, 0, 4],
  tokenPrice: [0, 0, 0, 0, 0]
};

// Create a chart instance
const ctx = document.getElementById("myChart").getContext("2d");
const myChart = new Chart(ctx, {
  type: "line",
  data: {
    labels: data.labels,
    datasets: [
      {
        label: "Proposals",
        data: data.proposals,
        borderColor: "rgb(255, 99, 132)",
        backgroundColor: "rgba(255, 99, 132, 0.2)",
        fill: true
      },
      {
        label: "Members",
        data: data.members,
        borderColor: "rgb(54, 162, 235)",
        backgroundColor: "rgba(54, 162, 235, 0.2)",
        fill: true
      },
      {
        label: "Token Price",
        data: data.tokenPrice,
        borderColor: "rgb(75, 192, 192)",
        backgroundColor: "rgba(75, 192, 192, 0.2)",
        fill: true
      }
    ]
  },
  options: {
    scales: {
      y: {
        beginAtZero: true
      }
    }
  }
});



const detailsTab = document.getElementById("detailsTab");

const proposalsTab =  document.getElementById("proposalsTab");

const pollsTab = document.getElementById("pollsTab");

const detailsSection = document.getElementById("details");

const pollsSection = document.getElementById("polls");

const proposalsSection = document.getElementById("proposals");

detailsTab.addEventListener("click", ()=>{
  detailsSection.style.display = "block";
  detailsTab.style.color = "#000";
  detailsTab.style.borderBottom = "2px solid #000";
  detailsTab.style.fontWeight = "bold";

  pollsSection.style.display = "none";
  pollsTab.style.color = "#a0a0a0";
  pollsTab.style.fontWeight = "normal";
  pollsTab.style.borderBottom = "none";

  proposalsSection.style.display = "none";
  proposalsTab.style.color = "#a0a0a0";
  proposalsTab.style.fontWeight = "normal";
  proposalsTab.style.borderBottom = "none";
});

proposalsTab.addEventListener("click", ()=>{
proposalsSection.style.display = "block";
proposalsTab.style.color = "#000";
  proposalsTab.style.fontWeight = "bold";
  proposalsTab.style.borderBottom = "2px solid #000";

detailsSection.style.display = "none";
detailsTab.style.color = "#a0a0a0";
  detailsTab.style.borderBottom = "none";
  detailsTab.style.fontWeight = "normal";


pollsSection.style.display = "none";
pollsTab.style.color = "#a0a0a0";
  pollsTab.style.fontWeight = "normal";
  pollsTab.style.borderBottom = "none";
});

pollsTab.addEventListener("click", ()=>{
  detailsSection.style.display = "none";
detailsTab.style.color = "#a0a0a0";
  detailsTab.style.borderBottom = "none";
  detailsTab.style.fontWeight = "normal";

  pollsSection.style.display = "block";
  pollsTab.style.color = "#000";
  pollsTab.style.fontWeight = "bold";
  pollsTab.style.borderBottom = "2px solid #000";

  proposalsSection.style.display = "none";
  proposalsTab.style.color = "#a0a0a0";
  proposalsTab.style.fontWeight = "normal";
  proposalsTab.style.borderBottom = "none";
});



// proposals innit 🤘

const createProposalButton = document.getElementById("createProposalButton");

const createProposalFormPopup = document.getElementById("createProposalFormPopup");

const closeCreateProposalIcon = document.getElementById("closeCreateProposalIcon2");

createProposalButton.addEventListener("click", ()=>{
  createProposalFormPopup.style.display = "block";
});

closeCreateProposalIcon.addEventListener("click", ()=>{
  createProposalFormPopup.style.display = "none";
});


// proposals dropdown

const gorvernorProposalDropDownIcon = document.getElementById("gorvernorProposalDropdownIcon");

const gorvernorProposalDropDownText = document.getElementById("gorvernorProposalDropdownText");

const paymentProposalDropDownIcon = document.getElementById("paymentProposalDropdownIcon");

const paymentProposalDropDownText = document.getElementById("paymentProposalDropdownText");

const fundingProposalDropDownIcon = document.getElementById("fundingProposalDropdownIcon");

const fundingProposalDropDownText = document.getElementById("fundingProposalDropdownText");

gorvernorProposalDropDownIcon.addEventListener("click", ()=>{
  gorvernorProposalDropDownText.style.display = "block";
  fundingProposalDropDownText.style.display = "none";
  paymentProposalDropDownText.style.display = "none";
});

paymentProposalDropDownIcon.addEventListener("click", ()=>{
  paymentProposalDropDownText.style.display = "block";
  fundingProposalDropDownText.style.display = "none";
  gorvernorProposalDropDownText.style.display = "none";
});

fundingProposalDropDownIcon.addEventListener("click", ()=>{
  fundingProposalDropDownText.style.display = "block";
  paymentProposalDropDownText.style.display = "none";
  gorvernorProposalDropDownText.style.display = "none";
});