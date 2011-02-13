/*function hidden_submit() {
  filterselect = document.getElementById('filter1')
  value = filterselect.options[filterselect.selectedIndex].value
  document.getElementById('actionfilter').value=value;
  document.getElementById('hiddenform1').submit();
}

function select_click() {
   filterselect = document.getElementById('filter1')
   value = filterselect.options[filterselect.selectedIndex].value
   $.ajax({
   type: "GET",
   data: "actionfilter="+value,
   url: '/actions/filter',
   success: function(data, type, xmlhttp){
     $("#div_actions").html(data);
   }
  });
}
*/

function setnavigation() {
  url = document.location.href;
  var navelement;
  if (url.indexOf('home') != -1) {
    navelement = document.getElementById('a_home');
    navelement.style.background="#E0EFFD";
  } else if (url.indexOf('bets') != -1) {
    navelement = document.getElementById('a_bets');
    navelement.style.background="#E0EFFD";
  } else if (url.indexOf('issues') != -1) {
    navelement = document.getElementById('a_issues');
    navelement.style.background="#E0EFFD";
  } else if (url.indexOf('members') != -1) {
    navelement = document.getElementById('a_members');
    navelement.style.background="#E0EFFD";
  } else if (url.indexOf('top') != -1) {
    navelement = document.getElementById('a_top');
    navelement.style.background="#E0EFFD";
  } else if (url.indexOf('login') != -1) {
    navelement = document.getElementById('a_login');
    navelement.style.background="#E0EFFD";
  }

  if (navelement)
    navelement.style.color="#000";
}
