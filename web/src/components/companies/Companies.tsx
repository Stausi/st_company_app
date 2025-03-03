import  './Companies.css'
import Company from '../company/Company';
import { CompanyIF } from '../App';

interface Props {
    companies: CompanyIF[];
    updateCompany: (newCompanyValue: number) => void;
}

const Companies: React.FC<Props> = ({ companies, updateCompany }) => {
    return (
        <div className='companies'>
            {companies.map((company, index) => (
                <Company key={index} updateCompany={updateCompany} index={index} company={company} />
            ))}
        </div>
    );
}

export default Companies;