import { LightningElement, wire } from 'lwc';

import getVFOrigin from '@salesforce/apex/vfCmpController.getVFOrigin';

import updateAccountSync from '@salesforce/apex/vfCmpController.updateAccountSync';
import updateAccountASync from '@salesforce/apex/vfCmpController.updateAccountASync';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class VfRemotingCmp extends LightningElement {

    error;
    AccountIds;
   searchKey;
    isLoading = false;
    length;
    displayBanner = false;

    @wire(getVFOrigin)
    vfOrigin;
    countLessthan10=false;

    

    handleSearchChange(event) {
        this.searchKey = event.target.value;
    }


    connectedCallback() {
        window.addEventListener("message", this.handleVFResponse.bind(this));
    }

    handleVFResponse(message) {
        if (message.origin === this.vfOrigin.data) {
            console.log('Came back to lightning');
            let newStr = message.data.replace(/\\/g, '');
           const obj = JSON.parse(newStr);
           this.isLoading=false;
            this.AccountIds=obj.AccIds;
            this.length=obj.length;
            console.log(obj.length);
            if(this.length<10000){
                this.countLessthan10=true
            }
            else{
                this.countLessthan10=false;
            }
           this.displayBanner = true;
            
        }
    }

    updateAccountsSync(){
        console.log('came to update Sync');
        this.isLoading=true;
        updateAccountSync({ids:this.AccountIds}).then(data=>{
           if(data){
               this.isLoading=false;
               this.displayBanner=false;
               this.countLessthan10=false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Accounts updated successfully',
                        variant: 'success',
                    }),
                );
   }
        //console.log(JSON.stringify(data.leftAccids));

        }).catch(errpr =>{
            console.log('error'+error);
            this.isLoading=false;
            this.displayBanner=false;
            this.countLessthan10=false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error while updating accounts',
                    variant: 'error',
                }),
            );


        });
    }

    updateAccountsASync(){
        console.log('came to update ASync');
        this.isLoading=true;
        updateAccountASync({ids:this.AccountIds}).then(data=>{
           if(data){
               this.isLoading=false;
               this.displayBanner=false;
               this.countLessthan10=false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Scheduled Apex to update accounts successfully',
                        variant: 'success',
                    }),
                );
   }
        //console.log(JSON.stringify(data.leftAccids));

        }).catch(errpr =>{
            console.log('error'+error);
            this.isLoading=false;
            this.displayBanner=false;
            this.countLessthan10=false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error while updating accounts',
                    variant: 'error',
                }),
            );
        });
    }
    
    handleFiretoVF() {
        this.isLoading=true;
        console.log('came to fire'+this.searchKey);
        this.template.querySelector("iframe").contentWindow.postMessage(this.searchKey, this.vfOrigin.data);
        console.log('came to fire2');
    }
}