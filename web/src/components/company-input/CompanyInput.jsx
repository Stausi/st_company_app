import React, { useState } from 'react';
import './CompanyInput.css'

const CompanyInput = (props) => {
    const { fetchNui } = window;
    
    const [message, setMessage] = useState('');
    const isDarkMode = props.darkMode;

    const statusText = props.company.status === true ? "Stå som Lukket" : "Stå som Åben";
    const onlineClass = props.company.status === true ? "red" : "green";
    const subClass = props.company.hasSub === true ? "green" : "";

    const handleMessageChange = event => {
        setMessage(event.target.value);
    };

    const handleFocus = event => {
        if(event.type === 'focus') {
            fetchNui("focusText", { status: true })
        };

        if(event.type === 'blur') {
            fetchNui("focusText", { status: false })
        };
    };

    async function handleSend() {
        await fetchNui("sendMessage", { message: message, job: props.company.job })
        props.updateCompany(-1);
    };

    async function handleToggleStatus() {
        await fetchNui("toggleStatus", { job: props.company.job })
    };

    async function handleSubStatus() {
        await fetchNui("subscribeToggle", { job: props.company.job })
    };
    
    return (
        <div className={`company-input ${isDarkMode ? "dark" : "light"}`}>
            <div className="company-inputs">
                { props.company.showStatus &&
                    <div className={`input-bell ${ subClass }`} onClick={() => handleSubStatus()} >
                        <i className="fa-regular fa-bell"></i>
                    </div>
                }
                <div className="input-image">
                    <img src={process.env.PUBLIC_URL + '/icons/' + props.company.img + '.png'} alt={props.company.name}/>
                </div>
                <div className="input-header">
                    <h1>{ props.company.name }</h1>
                </div>
                <div className="input-text">
                    <textarea rows="2" placeholder="Indtast besked..." value={message} onChange={handleMessageChange} onFocus={handleFocus} onBlur={handleFocus} />
                </div>
                <div className="input-buttons">
                    <button className="red" onClick={() => props.updateCompany(-1)}>Gå tilbage</button>
                    <button className="green" onClick={() => handleSend()}>Send besked</button>
                </div>
            </div>

            { (props.company.isWorker === true && props.company.showStatus) &&
                <div className="worker-button">
                    <button className={`${ onlineClass }`} onClick={() => handleToggleStatus()}>{ statusText }</button>
                </div>
            }
        </div>
    );
}

export default CompanyInput;