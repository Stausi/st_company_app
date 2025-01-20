import React, { useState } from 'react';
import  './CreatePost.css'

const CreatePost = (props) => {
    const { fetchNui } = window;
    
    const [title, setTitle] = useState('');
    const [message, setMessage] = useState('');
    const isDarkMode = props.darkMode;

    const handleTitleChange = event => {
        setTitle(event.target.value);
    };

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
        await fetchNui("sendPost", { title: title, image: props.image, message: message });
        props.setIsCreatingPost(false);
    };

    return (
        <div className={`company-input ${isDarkMode ? "dark" : "light"}`}>
            <div className="company-inputs">
                <div className="post-input-image">
                    <img src={ props.image } alt="Post"/>
                </div>
                <div className="input-text">
                    <input placeholder="Indtast titel..." value={title} onChange={handleTitleChange} onFocus={handleFocus} onBlur={handleFocus} />
                </div>
                <div className="input-text">
                    <textarea rows="1" placeholder="Indtast besked..." value={message} onChange={handleMessageChange} onFocus={handleFocus} onBlur={handleFocus} />
                </div>
                <div className="input-buttons">
                    <button className="green" onClick={() => handleSend()}>Post opslag</button>
                </div>
            </div>
        </div>
    );
}

export default CreatePost;