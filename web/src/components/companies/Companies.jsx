import  './Companies.css'
import Company from '../company/Company';

const Companies = (props) => {
    const isDarkMode = props.darkMode;

    return (
        <div className={`companies ${isDarkMode ? "dark" : "light"}`}>
            {props.companies.map((job, index) => (
                <Company key={index} darkMode={isDarkMode} updateCompany={props.updateCompany} index={index} job={job} />
            ))}
        </div>
    );
}

export default Companies;