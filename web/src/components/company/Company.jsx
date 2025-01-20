import './Company.css';
import { imageUrl } from '../App';

const Company = (props) => {
    const isDarkMode = props.darkMode;

    const showStatus = props.job.showStatus === true ? true : false;
    const statusText = props.job.status === true ? "Online" : "Offline";
    const onlineClass = props.job.status === true ? "online" : "offline";

    return (
        <div onClick={() => props.updateCompany(props.index)} className={`company ${isDarkMode ? "dark" : "light"}`}>
            <div id="company-section" className="company-image">
                <img src={imageUrl + '/icons/' + props.job.img + '.png'} alt={props.job.name}/>
            </div>
            <div id="company-section" className="company-name">
                <h1>{ props.job.name }</h1>
            </div>
            <div id="company-section" className="company-status">
                { showStatus === true &&
                    <>
                        <h2 className="company-status-text">{ statusText }</h2>
                        <div id="pulse" className={`company-status-circle ${ onlineClass }`}></div>
                    </>
                }
            </div>
        </div>
    );
}

export default Company;