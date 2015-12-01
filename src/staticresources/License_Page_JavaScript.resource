	var oldPermLic=false;
	var oldPerpLic=false;
	
	function confirmDisable(prodType)
        {
            var flag = false;
            if(prodType=="On-Premise")
            {
                flag = confirm("Are you sure you want to disable the license. The license will no longer receive any communications from this system.")
            }
            else
            {
                flag = confirm("Are you sure you want to disable the license. The license will no longer receive any communications from this system, and the license will be permanently removed from the SaaS Controller.")
            }
            
            return flag;
        }
	
	function confirmConvertToLite()
        {
			return confirm("Are you sure you want to convert the license to LITE license?")
        }
	
	function changeLicenseType(input,control1,control2,control3,eumLbl,eumVal,macAddrLblId,macAddrValId,permLicLblId,permLicValId,perpLicLblId,perpLicValId,coradiantLblId,coradiantValId,mode,oldProdType,expDateId,isPermanent){
		    var panel1 = document.getElementById(control1);
            var panel2 = document.getElementById(control2);
            var panel3 = document.getElementById(control3);
            var eumLblComp = document.getElementById(eumLbl);
            var eumValComp = document.getElementById(eumVal);
            var macAddrLbl = document.getElementById(macAddrLblId);
            var macAddrVal = document.getElementById(macAddrValId);

            var permLicLbl = document.getElementById(permLicLblId);
            var permLicVal = document.getElementById(permLicValId);
            var perpLicLbl = document.getElementById(perpLicLblId);
            var perpLicVal = document.getElementById(perpLicValId);

            var coRadiantLbl = document.getElementById(coradiantLblId);
            var coRadiantVal = document.getElementById(coradiantValId);
            
            var expDate = document.getElementById(expDateId); 
            //oldPermLic = permLicVal.checked;
            //oldPerpLic = perpLicVal.checked;
            
            if(input.value == "Hosted (SaaS)" )
            {
                panel1.style.display = 'block';
                panel2.style.display = 'block';
                panel3.style.display = 'block';
                eumLblComp.style.display = 'block';
                eumValComp.style.display = 'block';
                if(permLicLbl!=null)
                {
                	if(permLicVal.checked==true){
                		oldPermLic = true;
                		permLicVal.checked=false;
                		if(perpLicVal.checked==true){
                			oldPerpLic=true;
                			perpLicVal.checked=false;
                			expDate.disabled=false;
                		}
                	}
                    permLicLbl.style.display="none";
                    permLicVal.style.display="none";
                    //alert(isPermanent);
                    if(isPermanent)
                    {
                    	//alert("SUCCESS");
                    	perpLicLbl.style.display="block";
                    	perpLicVal.style.display="block";
                    }
                    else
                    {
                    	//alert("NONE");
                    	perpLicLbl.style.display="none";
                    	perpLicVal.style.display="none";
                    }
                    
                }
                if(eumValComp.checked == true)
                {
                    if(coRadiantLbl!=null)
                    {
                        coRadiantLbl.style.display="block";
                        coRadiantVal.style.display="block";
                    }
                }
                else
                {
                    if(coRadiantLbl!=null)
                    {
                        coRadiantLbl.style.display="none";
                        coRadiantVal.style.display="none";
                    }
                }
                if(macAddrLbl!=null)
                {
                    macAddrLbl.style.display = 'none';
                    macAddrVal.style.display = 'none';
                }
            }
            else if(input.value == "Hosted (SaaS Lite)"){
                panel1.style.display = 'block';
                panel2.style.display = 'block';
                panel3.style.display = 'block';
                eumLblComp.style.display = 'none';
                eumValComp.style.display = 'none';
                macAddrLbl.style.display = 'none';
                macAddrVal.style.display = 'none';
                if(permLicLbl!=null)
                {
                	if(permLicVal.checked==true){
                		oldPermLic = true;
                		permLicVal.checked=false;
                		if(perpLicVal.checked==true){
                			oldPerpLic=true;
                			perpLicVal.checked=false;
                			expDate.disabled=false;
                		}
                	}
                    permLicLbl.style.display="none";
                    permLicVal.style.display="none";
                    if(isPermanent)
                    {
                    	perpLicLbl.style.display="block";
                    	perpLicVal.style.display="block";
                    }
                    else
                    {
                    	perpLicLbl.style.display="none";
                    	perpLicVal.style.display="none";
                    }
                }
                if(coRadiantLbl!=null)
                {
                    coRadiantLbl.style.display="none";
                    coRadiantVal.style.display="none";
                }
                if(macAddrLbl!=null)
                {
                    macAddrLbl.style.display = 'none';
                    macAddrVal.style.display = 'none';
                }
            }
            else
            {
                panel1.style.display = 'none';
                panel2.style.display = 'none';
                panel3.style.display = 'none';
                eumLblComp.style.display = 'block';
                eumValComp.style.display = 'block';
                if(permLicLbl!=null)
                {
                	//if(permLicVal.checked==true)
                	{
                		permLicVal.checked=oldPermLic;
                		perpLicVal.checked=oldPerpLic;
                	}
                    permLicLbl.style.display="block";
                    permLicVal.style.display="block";
                    if(permLicVal.checked == true)
                    {
                        perpLicLbl.style.display="block";
                        perpLicVal.style.display="block";
                        if(perpLicVal.checked==true)
                        {
                        	expDate.disabled=true;
                        }
                        if(macAddrLbl!=null)
		                {
		                    macAddrLbl.style.display = 'block';
		                    macAddrVal.style.display = 'block';
		                }
                    }
                    else
                    {
                        perpLicLbl.style.display="none";
                        perpLicVal.style.display="none";
                    }
                }
                
                if(coRadiantLbl!=null)
                {
                     coRadiantLbl.style.display="none";
                     coRadiantVal.style.display="none";
                }
                
            }
            if(mode=="7")
            {
                if(oldProdType == "Hosted (SaaS)" || oldProdType == "Hosted (SaaS Lite)")
                {
                    if(input.value == "On-Premise")
                    {
                        var answer = confirm("You have chosen to change the license type for the license. The license will no longer receive any communications from this system, and the license will be permanently removed from the SaaS Controller. Please press cancel to revert back.");
                        if(answer == false)
                        {
                            input.value = oldProdType;
                            
                            panel1.style.display = 'block';
                			panel2.style.display = 'block';
                			panel3.style.display = 'block';
                			coRadiantLbl.style.display = 'block';
                			coRadiantLbl.style.display = 'block';
                        }
                        panel2.enabled=false;
                        //panel2.required=true;
                    } else {
                    	if(panel2.value=='') {
							panel2.enabled=true;
                        	//panel2.required=true; 
						} else {
							panel2.enabled=false;
                        	//panel2.required=true;
						}
                    }
                    
                }
                else
                {
                    if(input.value == "Hosted (SaaS)" || input.value == "Hosted (SaaS Lite)")
                    {
                        var answer1 = confirm("You have chosen to change the license type for the license. The license will no longer receive any communications from this system. Please press cancel to revert back.");
                        if(answer1 == false)
                        {
                           	input.value = oldProdType;
							panel1.style.display = 'none';
                			panel2.style.display = 'none';
                			panel3.style.display = 'none';
                        }
                        if(panel2.value=='')
                        {
							panel2.enabled=true;
                        	//panel2.required=true; 
						} 
							
                    } else {
                    	panel2.enabled=false;
                    	//panel2.required=false;
                    }
                }
            }
        }
        
        function handleEUMCoradiantURL(input,productTypeId,coradiantLblId,coradiantValId){
            var inputCheckBox = document.getElementById(input);
            var prodTypePanel = document.getElementById(productTypeId);
            var coradiantLbl = document.getElementById(coradiantLblId);
            var coradiantVal = document.getElementById(coradiantValId);
            var prodType = productTypeId;
            if(prodTypePanel!=null)
            {
            	prodType = prodTypePanel.value;
            }
            if(inputCheckBox.checked==true)
            {
                if(prodType == "Hosted (SaaS)")
                {
                    coradiantLbl.style.display = 'block';
                    coradiantVal.style.display = 'block';                            
                }
                else
                {
                    coradiantLbl.style.display = 'none';
                    coradiantVal.style.display = 'none';                            
                }
            }
            else
            {
                coradiantLbl.style.display = 'none';
                coradiantVal.style.display = 'none';
            }
        }
        
        function handleComponentsOnLoad(prodTypeId,lblId,valId,lbl2Id,eumLblId,eumValId,radiantLblId,radiantValId)
        {
            var prodType = document.getElementById(prodTypeId);
            var lbl1 = document.getElementById(lblId);
            var val1 = document.getElementById(valId);
            var lbl2 = document.getElementById(lbl2Id);
            var eumLbl = document.getElementById(eumLblId);
            var eumVal = document.getElementById(eumValId);
            var radiantLbl = document.getElementById(radiantLblId);
            var radiantVal= document.getElementById(radiantValId);
            
            var permLicense = document.getElementById('{!$Component.theBlock.theSection.permLicSection.permancentLicVal}');
            var perPetualLbl = document.getElementById('{!$Component.theBlock.theSection.perpetualLicSection.perpetualLicLbl}');
            var perPetualVal = document.getElementById('{!$Component.theBlock.theSection.perpetualLicSection.perpetualLicVal}');
            
            var macLbl= document.getElementById('{!$Component.theBlock.theSection.macSection.macLblId}');
            var macVal = document.getElementById('{!$Component.theBlock.theSection.macSection.macValId}');
            
            
            
            if(prodType.value == "Hosted (SaaS)"){
                lbl1.style.display = "block";
                val1.style.display = "block";
                lbl2.style.display = "block";
                if(eumVal.checked == true)
                {
                    radiantLbl.style.display = "block";
                    radiantVal.style.display = "block";
                }
                else
                {
                    radiantLbl.style.display = "none";
                    radiantVal.style.display = "none";
                }
                if(macLbl!=null)
                {
                    macLbl.style.display = "none";
                    macLbl.style.display = "none";
                    macVal.style.display = "none";
                    macVal.style.display = "none";
                }
                eumLbl.style.display="block";
                eumVal.style.display="block";
            }else if(prodType.value == "Hosted (SaaS Lite)"){
                lbl1.style.display = "block";
                val1.style.display = "block";
                lbl2.style.display = "block";
                radiantLbl.style.display = "none";
                radiantVal.style.display = "none";
                eumLbl.style.display="none";
                eumVal.style.display="none";
                if(macLbl!=null)
                {
                    macLbl.style.display = "none";
                    macLbl.style.display = "none";
                    macVal.style.display = "none";
                    macVal.style.display = "none";
                }
            }else{
                lbl1.style.display = "none";
                val1.style.display = "none";
                lbl2.style.display = "none";
                radiantLbl.style.display = "none";
                radiantVal.style.display = "none";
                eumLbl.style.display="block";
                eumVal.style.display="block";
                if(macLbl!=null)
                {
                    macLbl.style.display = "block";
                    macLbl.style.display = "block";
                    macVal.style.display = "block";
                    macVal.style.display = "block";
                }
            }
        }

        function togglePerpetualLicense(permanentLicenseId,productTypeId,perpetualLicenseLblId,perpetualLicenseValId, macLblId, macAddrId,expDateId)
        {
        	var permLicense = document.getElementById(permanentLicenseId);
            var prodType = document.getElementById(productTypeId);
            var perpetualLicenseLbl = document.getElementById(perpetualLicenseLblId);
            var perpetualLicenseVal = document.getElementById(perpetualLicenseValId);
            var macAddrLbl = document.getElementById(macLblId);
            var macAddr = document.getElementById(macAddrId);
            var expDateVal = document.getElementById(expDateId);
            var prodTypeVal = productTypeId;
            if(prodType!=null)
            {
            	prodTypeVal = prodType.value;
            }
            if(permLicense.checked==true)
            {
                if(prodTypeVal == "On-Premise")
                {
                    if(macAddr!=null)
                    {
                        macAddrLbl.style.display = 'block';            
                        macAddr.style.display = 'block';
                    }
                }
                else
                {
                    if(macAddr!=null)
                    {
                        macAddrLbl.style.display = 'none';
                        macAddr.style.display = 'none';
                    }
                }
                perpetualLicenseLbl.style.display='block';
                perpetualLicenseVal.style.display='block';
            }
            else
            {
                if(macAddr!=null)
                {
                    macAddrLbl.style.display = 'none';
                    macAddr.style.display = 'none';
                }
                perpetualLicenseVal.checked=false;
                perpetualLicenseLbl.style.display='none';
                perpetualLicenseVal.style.display='none';
                
                expDateVal.disabled = false;
	            if(prevDateVal!=null)
	            {
	            	expDateVal.value = prevDateVal;//'{!licenseDetailObj.License_Expiry_Date__c}';
	            }
            }
        }
        var prevDateVal;
        function handlePerpetualLicenseClick(perpetualLicId,expDateId)
        {
            var perpLic = document.getElementById(perpetualLicId);
            var expDateVal = document.getElementById(expDateId);
            if(perpLic.checked == true)
            {
                prevDateVal = expDateVal.value;
                expDateVal.disabled = true;
                expDateVal.value = '01/01/2038';//'{!perpetualLicExpDate}';
            }
            else
            {
                expDateVal.disabled = false;
                if(prevDateVal!=null)
                {
                    expDateVal.value = prevDateVal;//'{!licenseDetailObj.License_Expiry_Date__c}';
                }
            }
        }
        
        
        
        
        function disableComponents(mode,saasLblId,saasUrlValId,saasLbl2Id,macLblId,macValId,eumLblId,eumValId,coRadiantLblId,coRadiantValId,prodTypeId,permLicLblId,permLicValId,perpLicLblId,perpLicValId,expDateId,isPermanent)
        {
	

            var saasURLVal = document.getElementById(saasUrlValId);
            var eumVal = document.getElementById(eumValId);
            var coRadiantVal = document.getElementById(coRadiantValId);
            
            var prodType = document.getElementById(prodTypeId);
            var permLicLbl = document.getElementById(permLicLblId);
            var permLicVal = document.getElementById(permLicValId);
            var perpLicLbl = document.getElementById(perpLicLblId);
            var perpLicVal = document.getElementById(perpLicValId);
            
            var saasLbl = document.getElementById(saasLblId);
            var saasLbl2 = document.getElementById(saasLbl2Id);
            var macLbl = document.getElementById(macLblId);
            var macVal = document.getElementById(macValId);
            var eumLbl = document.getElementById(eumLblId);
            var coRadiantLbl = document.getElementById(coRadiantLblId);
            var expDateVal = document.getElementById(expDateId);
            var prodTypeVal = prodTypeId;

console.log('prodTypeVal'+ prodTypeVal);

console.log('saasURLVal'+ saasURLVal);

	console.log('saasLbl'+ saasLbl);
	console.log('mode'+ mode);

            if(prodType!=null)
            {
            	prodTypeVal = prodType.value;
            }
            if(prodTypeVal == "On-Premise")
	        {
	                if(permLicLbl!=null)
	                {
	                    if(permLicVal.checked == true)
	                    {
	                        perpLicLbl.style.display = 'block';
	                        perpLicVal.style.display = 'block';
	                        if(macLbl!=null){
	                        	macLbl.style.display = 'block';
	                        	macVal.style.display = 'block';
	                        }
	                    }
	                    else
	                    {
	                        perpLicLbl.style.display = 'none';
	                        perpLicVal.style.display = 'none';
	                        if(macLbl!=null){
	                        	macLbl.style.display = 'none';
	                        	macVal.style.display = 'none';
	                        }
	                    }
	                }
					if(saasLbl != null) {
		                saasLbl.style.display='none';
					}
					if(saasURLVal != null) {
						saasURLVal.style.display='none';
					}
					if(saasLbl2 != null) {
		                saasLbl2.style.display='none';
					}
					if(eumLbl != null) {
						eumLbl.style.display = 'block';
					}
					if(eumVal != null) {
						eumVal.style.display = 'block';
					}
	                
	                if(coRadiantLbl!=null){
	                	coRadiantLbl.style.display = 'none';
	                	coRadiantVal.style.display = 'none';
	                }                            
	            }
	            else if(prodTypeVal == "Hosted (SaaS)")
	            {	console.log('enter====='+ prodTypeVal+'permLicLbl ======'+ permLicLbl+'permLicVal====='+permLicVal);
	                if(permLicLbl!=null)
	                {
	                    permLicLbl.style.display='none';
	                    permLicVal.style.display='none';
                               console.log('if perpLicLbl===='+perpLicLbl+'perpLicVal===='+perpLicVal);
                        if(perpLicLbl != null && perpLicVal != null)
                        {       

		                    if(isPermanent)
		                    {
		                    	perpLicLbl.style.display='block';
		                    	perpLicVal.style.display='block';
		                    }
		                    else
		                    {
		                    	perpLicLbl.style.display='none';
		                    	perpLicVal.style.display='none';
		                    }
						}
	                }
console.log('eumLbl====='+ eumLbl+'eumVal ======'+ eumVal);
                        if(eumLbl!=null){
	                   eumLbl.style.display = 'block';
                        }
                        if(eumVal!=null){
			   eumVal.style.display = 'block';
 	                   if(eumVal.checked == true)
	                   {
	                      coRadiantLbl.style.display = 'block';
	                      coRadiantVal.style.display = 'block';
	                  }
	                  else
	                  {
	                      coRadiantLbl.style.display = 'none';
	                      coRadiantVal.style.display = 'none';
	                  }
			}
	                if(macLbl!=null)
	                {
	                    macLbl.style.display = 'none';
	                    macVal.style.display = 'none';
	                }                
console.log('before saasLbl====='+ saasLbl+'saasURLVal ======'+ saasURLVal+'saasLbl2==='+saasLbl2);
	                saasLbl.style.display='block';
	                //saasURLVal.style.display='block';
	                //saasLbl2.style.display='block';
console.log('After saasLbl====='+ saasLbl+'saasURLVal ======'+ saasURLVal+'saasLbl2==='+saasLbl2);
	            }
	            else if(prodTypeVal == "Hosted (SaaS Lite)")
	            {
	                if(permLicLbl!=null)
	                {
	                    permLicLbl.style.display='none';
	                    permLicVal.style.display='none';
	                    if(isPermanent)
	                    {
	                    	perpLicLbl.style.display='block';
	                    	perpLicVal.style.display='block';
	                    }
	                    else
	                    {
	                    	perpLicLbl.style.display='none';
	                    	perpLicVal.style.display='none';
	                    }
	                }
	                saasLbl.style.display='block';
	                saasURLVal.style.display='block';
	                saasLbl2.style.display='block';
	                if(eumLbl!=null)
	                {
	                    eumLbl.style.display = 'none';
	                    eumVal.style.display = 'none';
	                }
	                if(coRadiantLbl!=null)
	                {
	                    coRadiantLbl.style.display = 'none';
	                    coRadiantVal.style.display = 'none';
	                }
	                if(macLbl!=null)
	                {
	                    macLbl.style.display = 'none';
	                    macVal.style.display = 'none';
	                }
	            }
            
            if(mode=="4" || mode=="9")
            {
            	if(prodType!=null)
            	{
                	prodType.disabled=false;
                }
                saasURLVal.disabled = false;
                coRadiantVal.disabled = false;
                if(mode=="9")
                {
                	if(perpLicVal!=null)
	                {
	                	if(perpLicVal.checked == true)
	                	{
	                		expDateVal.disabled = true;
	                	}
	                	else
	                	{
	                		expDateVal.disabled = false;
	                	}
	                }
                }
            }
            else if(mode=="5")
            {console.log('saasURLVal 555555'+ saasURLVal);
            	if(prodType!=null)
            	{
                	prodType.disabled=true;
                }
                saasURLVal.disabled = true;
                if(coRadiantVal !=null)
                {
                    if(coRadiantVal.value == '')
                    {
                        coRadiantVal.disabled = false;
                    }
                    else
                    {
                        coRadiantVal.disabled = false;
                    }
                }
                if(perpLicVal!=null)
                {
                	if(perpLicVal.checked == true)
                	{
                		expDateVal.disabled = true;
                	}
                	else
                	{
                		expDateVal.disabled = false;
                	}
                }
            }
            else if(mode=="6")
            {console.log('saasURLVal 6666666'+ saasURLVal);
            	if(prodType!=null)
            	{
                	prodType.disabled=true;
                }
                saasURLVal.disabled = true;
                if(coRadiantVal !=null)
                {
                    if(coRadiantVal.value == '')
                    {
                        coRadiantVal.disabled = false;
                    }
                    else
                    {
                        coRadiantVal.disabled = false;
                    }
                }
                if(perpLicVal!=null)
                {
                	if(perpLicVal.checked == true)
                	{
                		expDateVal.disabled = true;
                	}
                	else
                	{
                		expDateVal.disabled = false;
                	}
                }
            }
            else if(mode=="7")
            {
            	if(prodType!=null)
            	{
                	prodType.disabled=false;
                }
                if(saasURLVal.value == '')
                {
                	saasURLVal.disabled = false;
                }
                else
                {
                	saasURLVal.disabled = true;
                }
                if(perpLicVal!=null)
                {
                	if(perpLicVal.checked == true)
                	{
                		expDateVal.disabled = true;
                	}
                	else
                	{
                		expDateVal.disabled = false;
                	}
                }
                if(coRadiantVal !=null)
                {
                    if(coRadiantVal.value == '')
                    {
                        coRadiantVal.disabled = false;
                    }
                    else
                    {
                        coRadiantVal.disabled = false;
                    }
                }
            }
        }



function disableAfterTimeout(obj){
//console.log('disableAfterTimeout'+obj);
   setTimeout(function(){
       		//console.log(obj);
	$('input[type="submit"][value="'+obj.value+'"]')[0].disabled='disabled';
	$('input[type="submit"][value="'+obj.value+'"]')[0].className = 'btnDisabled';
    		
	$('input[type="submit"][value="'+obj.value+'"]')[1].disabled='disabled';
	$('input[type="submit"][value="'+obj.value+'"]')[1].className = 'btnDisabled';
    		
	//console.log($(obj).next().attr('name'));
    		
	$('input[type="submit"][value="'+$(obj).next().attr('value')+'"]')[0].disabled='disabled';
	$('input[type="submit"][value="'+$(obj).next().attr('value')+'"]')[0].className = 'btnDisabled';
    		
	$('input[type="submit"][value="'+$(obj).next().attr('value')+'"]')[1].disabled='disabled';
	$('input[type="submit"][value="'+$(obj).next().attr('value')+'"]')[1].className = 'btnDisabled';
	//console.log('before save call'); 

   }, 50);
}
