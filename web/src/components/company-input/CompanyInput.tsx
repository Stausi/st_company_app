import React, { useState } from 'react';
import './CompanyInput.css';
import { imageUrl, CompanyIF } from '../App';

type CompanyInputProps = {
    company: CompanyIF;
    updateCompany: (value: number) => void;
};

const CompanyInput: React.FC<CompanyInputProps> = ({ company, updateCompany }) => {
    const [message, setMessage] = useState<string>('');

    const statusText = company.status ? "Stå som Lukket" : "Stå som Åben";
    const onlineClass = company.status ? "red" : "green";
    const subClass = company.hasSub ? "green" : "";

    const handleMessageChange = (event: React.ChangeEvent<HTMLTextAreaElement>) => {
        setMessage(event.target.value);
    };

    const handleFocus = (event: React.FocusEvent<HTMLTextAreaElement>) => {
        fetchNui("focusText", { status: event.type === 'focus' });
    };

    const handleSend = async () => {
        await fetchNui("sendMessage", { message, job: company.job });
        updateCompany(-1);
    };

    const handleToggleStatus = async () => {
        await fetchNui("toggleStatus", { job: company.job });
    };

    const handleSubStatus = async () => {
        await fetchNui("subscribeToggle", { job: company.job });
    };
    
    return (
        <div className="company-input">
            <div className="company-inputs">
                {company.showStatus && (
                    <div className={`input-bell ${subClass}`} onClick={handleSubStatus}>
                        <i className="fa-regular fa-bell"></i>
                    </div>
                )}
                <div className="input-image">
                    <img src={`${imageUrl}/icons/${company.image}.png`} alt={company.name} />
                </div>
                <div className="input-header">
                    <h1>{company.name}</h1>
                </div>
                <div className="input-text">
                    <textarea 
                        rows={2} 
                        placeholder="Indtast besked..." 
                        value={message} 
                        onChange={handleMessageChange} 
                        onFocus={handleFocus} 
                        onBlur={handleFocus} 
                    />
                </div>
                <div className="input-buttons">
                    <button className="red" onClick={() => updateCompany(-1)}>Gå tilbage</button>
                    <button className="green" onClick={handleSend}>Send besked</button>
                </div>
            </div>

            {company.isWorker && company.showStatus && (
                <div className="worker-button">
                    <button className={onlineClass} onClick={handleToggleStatus}>{statusText}</button>
                </div>
            )}
        </div>
    );
};

export default CompanyInput;