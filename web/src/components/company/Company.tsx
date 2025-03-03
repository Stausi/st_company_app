import './Company.css';
import { imageUrl, CompanyIF } from '../App';

interface Props {
    company: CompanyIF;
    index: number;
    updateCompany: (newCompanyValue: number) => void;
}

const Company: React.FC<Props> = ({ company, index, updateCompany }) => {
    const showStatus = company.showStatus === true ? true : false;
    const statusText = company.status === true ? "Online" : "Offline";
    const onlineClass = company.status === true ? "online" : "offline";

    return (
        <div onClick={() => updateCompany(index)} className='company'>
            <div id="company-section" className="company-image">
                <img src={imageUrl + '/icons/' + company.image + '.png'} alt={company.name}/>
            </div>
            <div id="company-section" className="company-name">
                <h1>{ company.name }</h1>
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