import './PlayerJob.css';

const PlayerJob = (props) => {
    const { fetchNui } = window;

    async function TakePlayerJob() {
        await fetchNui("takePlayerJob", { job: props.job })
    };

    async function QuitPlayerJob() {
        await fetchNui("quitPlayerJob", { job: props.job })
    };

    return (
        <div className={`playerJob`}>
            <div className="playerJob-name">
                <h1>{ props.job.name }</h1>
            </div>

            <div className="playerJob-buttons">
                { !props.job.hasJob &&
                    <button className="playerJob-action" onClick={() => TakePlayerJob()}>
                        Tag Job
                    </button>
                }

                { !props.job.disableResign &&
                    <button className="playerJob-action" onClick={() => QuitPlayerJob()}>
                        Opsig Job
                    </button>
                }
            </div>
        </div>
    );
}

export default PlayerJob;