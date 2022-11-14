/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('sexChromosome', {
		id_sexChromosome: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_sexchromosome::regclass)",
			primaryKey: true
		},
		fk_dna_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'dna',
				key: 'id_adn'
			}
		}
	}, {
		tableName: 'sexChromosome',
		timestamps: false
	});
};
