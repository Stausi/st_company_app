import './PlayerJob.css';
import { CompanyIF } from '../App';

interface Props {
    job: CompanyIF;
}

const PlayerJob: React.FC<Props> = ({ job }) => {
    async function TakePlayerJob() {
        await fetchNui("takePlayerJob", { job: job })
    };

    async function QuitPlayerJob() {
        await fetchNui("quitPlayerJob", { job: job })
    };

    return (
        <div className={`playerJob`}>
            <div className="playerJob-name">
                <h1>{ job.name }</h1>
            </div>

            <div className="playerJob-buttons">
                { !job.hasJob &&
                    <button className="playerJob-action" onClick={() => TakePlayerJob()}>
                        Tag Job
                    </button>
                }

                { !job.disableResign &&
                    <button className="playerJob-action" onClick={() => QuitPlayerJob()}>
                        Opsig Job
                    </button>
                }
            </div>
        </div>
    );
}

export default PlayerJob;