import React, { useState } from 'react';
import './CreatePost.css';

type CreatePostProps = {
    image: string;
    setIsCreatingPost: (value: boolean) => void;
};

const CreatePost: React.FC<CreatePostProps> = ({ image, setIsCreatingPost }) => {
    const [title, setTitle] = useState<string>('');
    const [message, setMessage] = useState<string>('');

    const handleTitleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        setTitle(event.target.value);
    };

    const handleMessageChange = (event: React.ChangeEvent<HTMLTextAreaElement>) => {
        setMessage(event.target.value);
    };

    const handleFocus = (event: React.FocusEvent<HTMLInputElement | HTMLTextAreaElement>) => {
        fetchNui("focusText", { status: event.type === 'focus' });
    };

    const handleSend = async () => {
        await fetchNui("sendPost", { title, image, message });
        setIsCreatingPost(false);
    };

    return (
        <div className='company-input'>
            <div className="company-inputs">
                <div className="post-input-image">
                    <img src={image} alt="Post" />
                </div>
                <div className="input-text">
                    <input 
                        placeholder="Indtast titel..." 
                        value={title} 
                        onChange={handleTitleChange} 
                        onFocus={handleFocus} 
                        onBlur={handleFocus} 
                    />
                </div>
                <div className="input-text">
                    <textarea 
                        rows={1} 
                        placeholder="Indtast besked..." 
                        value={message} 
                        onChange={handleMessageChange} 
                        onFocus={handleFocus} 
                        onBlur={handleFocus} 
                    />
                </div>
                <div className="input-buttons">
                    <button className="green" onClick={handleSend}>Post opslag</button>
                </div>
            </div>
        </div>
    );
};

export default CreatePost;