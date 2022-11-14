/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('lote', {
		id_lote: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_lote::regclass)",
			primaryKey: true
		},
		tipo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		nmi: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		estructura_nmi: {
			type: DataTypes.STRING,
			allowNull: true
		},
		observaciones: {
			type: DataTypes.STRING,
			allowNull: true
		},
		unid_estratigrafica: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'lote',
		timestamps: false
	});
};
